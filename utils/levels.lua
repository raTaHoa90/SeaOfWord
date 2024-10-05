require "utils.strings"
local Array = require "utils.arrays"

local sizeSprite = 75

local LevelWord = {
	words = Array({}),
	this_level = 1
}

function LevelWord:initLevels(words)
	if self.words:Length() > 0 then
		for i, lineObj in ipairs(self.words) do
			msg.post(lineObj.line, "destroy_word")
		end
		self.words = Array({})
	end
	
	local uniqueLetters = Array({})
	local lines_id = go.get_id("/lines_word")
	local scale = vmath.vector3(1, 1, 1)
	local start_y = 880
	if #words > 5 then
		local delta = 400 / #words
		scale.x = delta / sizeSprite
		scale.y = scale.x
		if #words > 8 then
			start_y = 900
		elseif #words > 6 then
			start_y = 890
		end
	end
	go.set_scale(scale, lines_id)
	
	for i, word in ipairs(words) do
		local equLettersPos = Array({})
		local line = factory.create("/game#letters_line", 
			vmath.vector3(0, start_y - (i - 1) * sizeSprite * scale.y, 0.2), 
			nil, {parent_id = lines_id},
			scale
		)
		msg.post(line, "init_word", {word = word})
		local lineObj = {
			word = word,
			line = line,
			letters = word:array(),
			active = true
		}
		self.words:Push(lineObj)

		local addUniqueLetter = function(letter)
			local ps = uniqueLetters:Push(letter)
			equLettersPos:Push(ps)
		end
		
		for i, letter in ipairs(lineObj.letters) do
			local ps = uniqueLetters:IndexOf(letter)
			if ps == -1 then 
				addUniqueLetter(letter)
			else
				local res = equLettersPos:IndexOf(ps) > -1
				while res do
					ps = uniqueLetters:IndexOf(letter, ps + 1)
					if ps == -1 then 
						addUniqueLetter(letter)
						res = false;
					else
						res = equLettersPos:IndexOf(ps) > -1
					end
				end
				if ps > -1 then
					equLettersPos:Push(ps)
				end
			end
		end
	end
	self.unique_letters = Array(uniqueLetters:Shuffle())
	return self.unique_letters
end

function LevelWord:getLineWord(word)
	for i, lineObj in ipairs(self.words) do
		if lineObj.active and lineObj.word == word then
			return lineObj
		end
	end
	return nil
end

function LevelWord:isAllComplete()
	for i, lineObj in ipairs(self.words) do
		if lineObj.active then
			return false
		end
	end
	return true
end

local function utf8StrSort(a, b)
	return a:length() < b:length()
end

local function callbackLoad(self, id, response)
	local level = json.decode(response.response)

	local wordArray = level.words
	table.sort(wordArray, utf8StrSort)

	local letters = LevelWord:initLevels(wordArray)
	msg.post("/letters_cr_line", "init_letters", {letters = letters})

	if html5 and #LevelWord.words_save > 0 then 
		for i, word in ipairs(LevelWord.words_save) do
			local lineObj = LevelWord:getLineWord(word)
			if lineObj then
				lineObj.active = false
				msg.post(lineObj.line, "view_word", { word = word, good = true })
				html5.run("jsApp.levelAddWord('"..word.."')")
			end
		end
		LevelWord.words_save = nil
		if LevelWord:isAllComplete() then
			LevelWord:next()
		end
	end
end

function LevelWord:loadLevel(num)
	local fileNum = ((num - 1) % 3) + 1
	html5.run("jsApp.levelStart("..num..")")
	http.request("js/levels/"..fileNum..".json", "GET", callbackLoad )
	
	--local levels = {"ТЕСТ","ТЕКСТ", "ТОСТ", "ТОРТ", "КОРТ", "РОТ", "КОТ","ТОК","РОСТ", "РОК", "СОРТ", "СОК", "ТРЕК"}
	--local letters = self:initLevels({levels[num]}) -- "ТЕКСТ", "ТОСТ", "ТОРТ", "КОРТ", "РОТ", "КОТ","ТОК","РОСТ", "РОК", "СОРТ", "СОК", "ТРЕК"})
	--msg.post("/letters_cr_line", "init_letters", {letters = letters})
end

function LevelWord:load()
	local words = {}
	if html5 then
		self.this_level = html5.run("jsApp.storage.get('save_level',1)")
		self.this_level = tonumber(self.this_level)
		self.words_save = json.decode(html5.run("jsApp.levelWords()"))
	end
	self:loadLevel(self.this_level)
	msg.post("/mainmenu", "set_level", {level = self.this_level})
end

function LevelWord:next()
	self.this_level = self.this_level + 1
	msg.post("/mainmenu", "set_level", {level = self.this_level})
	msg.post("/mainmenu", "next_level")
	self:loadLevel(self.this_level)
end

return LevelWord