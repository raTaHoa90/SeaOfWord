local utf8 = require "utils.utf8"
local mt = getmetatable("String")

--[[
Library «Strings», v2.0
Custom strings methods 

Author: Cosmo
VK: vk.me/cosui
TG: t.me/cosmo_way
BH: blast.hk/members/217639

Edited by raTaHoa
]]

function mt.__index:length()
	return utf8.len(self)
end

function mt.__index:insert(implant, pos)
	if pos == nil then
		return self .. implant
	end
	return utf8.sub(self, 1, pos) .. implant .. utf8.sub(self, pos + 1)
end

function mt.__index:extract(pattern)
	self = utf8.utf8gsub(self, pattern, "")
	return self
end

function mt.__index:array()
	local array = {}
	for s in utf8.gmatch(self,".") do
		array[#array + 1] = s
	end
	return array
end

function mt.__index:isEmpty()
	return utf8.find(self, "%S") == nil
end

function mt.__index:isDigit()
	return utf8.find(self, "%D") == nil
end

function mt.__index:isAlpha()
	return utf8.find(self, "[%d%p]") == nil
end

function mt.__index:split(sep, plain)   
	local result, pos = {}, 1
	repeat
		local s, f = utf8.find(self, sep or " ", pos, plain)
		local t = utf8.sub(self,pos, s and s - 1)
		if t ~= "" then
			result[#result + 1] = t
		end
		pos = f and f + 1
	until pos == nil
	return result
end

function mt.__index:isSpace()
	return utf8.find(self, "^[%s%c]*$") ~= nil
end

function mt.__index:isUpper()
	return utf8.upper(self) == self
end

function mt.__index:isLower()
	return utf8.lower(self) == self
end

function mt.__index:isSimilar(str)
	return self == str
end

function mt.__index:isTitle()
	local p = utf8.find(self, "[A-zА-яЁё]")
	local let = utf8.sub(self, p, p)
	return let:isSimilar(let:upper())
end

function mt.__index:startsWith(str)
	return utf8.sub(self, 1, #str):isSimilar(str)
end

function mt.__index:endsWith(str)
	return utf8.sub(self, self:length() - #str + 1, self:length()):isSimilar(str)
end

function mt.__index:capitalize()
	local cap = utf8.sub(self, 1, 1):upper()
	self = utf8.gsub(self, "^.", cap)
	return self
end

function mt.__index:tabsToSpace(count)
	local spaces = (" "):rep(count or 4)
	self = utf8.gsub(self, "\t", spaces)
	return self
end

function mt.__index:spaceToTabs(count)
	local spaces = (" "):rep(count or 4)
	self = utf8.gsub(self, spaces, "\t")
	return self
end

function mt.__index:center(width, char)
	local len = width - self:length()
	local s = string.rep(char or " ", len) 
	return s:insert(self, math.ceil(len / 2))
end

function mt.__index:count(search, p1, p2)
	local area = utf8.sub(self, p1 or 1, p2 or self:length())
	local count, pos = 0, p1 or 1
	repeat
		local s, f = area:find(search, pos, true)
		count = s and count + 1 or count
		pos = f and f + 1
	until pos == nil
	return count
end

function mt.__index:trimEnd()
	self = utf8.gsub(self, "%s*$", "")
	return self
end

function mt.__index:trimStart()
	self = utf8.gsub(self, "^%s*", "")
	return self
end

function mt.__index:trim()
	self = utf8.match(self, "^%s*(.-)%s*$")
	return self
end

function mt.__index:swapCase()
	local result = {}
	for s in utf8.gmatch(self, ".") do
		if s:isAlpha() then
			s = s:isLower() and s:upper() or s:lower()
		end
		result[#result + 1] = s
	end
	return table.concat(result)
end

function mt.__index:splitEqually(width)
	assert(width > 0, "Width less than zero")
	if width >= self:length() then
		return { self }
	end

	local result, i = {}, 1
	repeat
		if #result == 0 or #result[#result] >= width then
			result[#result + 1] = ""
		end
		result[#result] = result[#result] .. utf8.sub(self, i, i)
		i = i + 1
	until i > self:length()
	return result
end

function mt.__index:rFind(pattern, pos, plain)
	local i = pos or self:length()
	repeat
		local result = { self:find(pattern, i, plain) }
		if next(result) ~= nil then
			return table.unpack(result)
		end
		i = i - 1
	until i <= 0
	return nil
end

function mt.__index:wrap(width)
	assert(width > 0, "Width less than zero")
	assert(width < self:len(), "Width is greater than the string length")
	local pos = 1
	self = self:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
		if fi - pos > (width or 72) then
			pos = st
			return "\n" .. word
		end
	end)
	return self
end

function mt.__index:levDist(str)
	if self:length() == 0 then
		return str:length()
	elseif str:length() == 0 then
		return self:length()
	elseif self == str then
		return 0
	end

	local matrix = {}
	for i = 0, self:length() do matrix[i] = {}; matrix[i][0] = i end
	for i = 0, str:length() do matrix[0][i] = i end
	for i = 1, self:length(), 1 do
		for j = 1, #str, 1 do
			local cost = self:byte(i) == str:byte(j) and 0 or 1
			matrix[i][j] = math.min(
			matrix[i - 1][j] + 1,
			matrix[i][j - 1] + 1,
			matrix[i - 1][j - 1] + cost
		)
		end
	end
	return matrix[self:length()][str:length()]
end

function mt.__index:getSimilarity(str)
	local dist = self:levDist(str)
	return 1 - dist / math.max(self:length(), str:length())
end

function mt.__index:empty()
	return ""
end

function mt.__index:toCamel()
	local arr = self:array()
	for i, let in ipairs(arr) do
		arr[i] = (i % 2 == 0) and let:lower() or let:upper()
	end
	return table.concat(arr)
end

function mt.__index:unplain()
	local arr = self:array()
	for i, let in ipairs(arr) do
		if let:find("().%+-*?[]^$", 1, true) then
			arr[i] = "%" .. let
		end
	end
	return table.concat(arr)
end

function mt.__index:shuffle(seed)
	math.randomseed(seed or os.time())
	local arr = self:array()
	for i = #arr, 2, -1 do
		local j = math.random(i)
		arr[i], arr[j] = arr[j], arr[i]
	end
	return table.concat(arr)
end

function mt.__index:cutLimit(max_len, symbol)
	assert(max_len > 0, "Maximum length cannot be less than or equal to 1")
	if self:length() > 0 and self:length() > max_len then
		symbol = symbol or ".."
		self = utf8.sub(self, 1, max_len) .. symbol
	end
	return self
end

function mt.__index:switchLayout()
	local result = ""
	local b = utf8.find(self, "^[%s%p]*%a") ~= nil
	local t = {
		{"а", "f"}, {"б", ","}, {"в", "d"}, 
		{"г", "u"}, {"д", "l"}, {"е", "t"}, 
		{"ё", "`"}, {"ж", ";"}, {"з", "p"}, 
		{"и", "b"}, {"й", "q"}, {"к", "r"}, 
		{"л", "k"}, {"м", "v"}, {"н", "y"}, 
		{"о", "j"}, {"п", "g"}, {"р", "h"}, 
		{"с", "c"}, {"т", "n"}, {"у", "e"}, 
		{"ф", "a"}, {"х", "["}, {"ц", "w"}, 
		{"ч", "x"}, {"ш", "i"}, {"щ", "o"}, 
		{"ь", "m"}, {"ы", "s"}, {"ъ", "]"}, 
		{"э", "'"}, {"/", "."}, {"я", "z"}, 
		{"А", "F"}, {"Б", "<"}, {"В", "D"}, 
		{"Г", "U"}, {"Д", "L"}, {"Е", "T"}, 
		{"Ё", "~"}, {"Ж", ":"}, {"З", "P"}, 
		{"И", "B"}, {"Й", "Q"}, {"К", "R"}, 
		{"Л", "K"}, {"М", "V"}, {"Н", "Y"}, 
		{"О", "J"}, {"П", "G"}, {"Р", "H"}, 
		{"С", "C"}, {"Т", "N"}, {"У", "E"}, 
		{"Ф", "A"}, {"Х", "{"}, {"Ц", "W"}, 
		{"Ч", "X"}, {"Ш", "I"}, {"Щ", "O"}, 
		{"Ь", "M"}, {"Ы", "S"}, {"Ъ", "}"}, 
		{"Э", "\""}, {"Ю", ">"}, {"Я", "Z"}
	}

	for l in utf8.gmatch(self, ".") do
		local fined = false
		for _, v in ipairs(t) do
			if l == v[b and 2 or 1] then
				l = v[b and 1 or 2]
				fined = true
				break
			end
		end
		if not fined then
			for _, v in ipairs(t) do
				if l == v[b and 1 or 2] then
					l = v[b and 2 or 1]
					break
				end
			end
		end
		result = (result .. l)
	end
	return result
end