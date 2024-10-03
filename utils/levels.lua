require "utils.strings"
local Array = require "utils.arrays"

local sizeSprite = 75

local levelWords = {
	words = Array({})
}

function levelWords:initLevels(words)
	local uniqueLetters = Array({})
	local lines_id = go.get_id("/lines_word")
	local scale = vmath.vector3(1, 1, 1)
	if #words > 5 then
		local delta = 400 / #words
		scale.x = delta / sizeSprite
		scale.y = scale.x
	end
	go.set_scale(scale, lines_id)
	
	for i, word in ipairs(words) do
		local equLettersPos = Array({})
		local line = factory.create("#letters_line", 
			vmath.vector3(0, 900 - (i - 1) * sizeSprite * scale.y, 0.2), 
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

function levelWords:getLineWord(word)
	for i, lineObj in ipairs(self.words) do
		if lineObj.active and lineObj.word == word then
			return lineObj
		end
	end
	return nil
end

return levelWords