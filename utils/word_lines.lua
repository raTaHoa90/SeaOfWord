require "utils.strings"

local w_screen = sys.get_config_number("display.width")
--local h_screen = sys.get_config_number("display.height")

local WordLines = {}
local sizeSprite = 75

function WordLines:new(word)
	local o = setmetatable({__instanceof=self}, self)
	self.__index = self
	o.word = word
	o.letters = word:array()
	return o
end

function WordLines:size()
	return self.word:length()
end

function WordLines:createCells(id_parent)
	self.parent = id_parent
	local parent_position = go.get_world_position(id_parent)
	local parent_scale = go.get_world_scale(id_parent)
	local delta_x = (w_screen - parent_scale.x * sizeSprite * (self.word:length() - 1)) / 2


	self.cells = {}
	for i = 1, self.word:length() do
		local position = vmath.vector3(delta_x + parent_scale.x * sizeSprite * (i - 1), parent_position.y, parent_position.z)
		local newCell = factory.create("#letter_sq_factory", position)

		self.cells[i] = newCell
		msg.post(newCell, "set_parent", {parent_id = self.parent})
	end
end

function WordLines:destroy()
	if self.cells then 
		for k, cell in ipairs(self.cells) do
			go.delete(cell, true)
		end
	end
end

function WordLines:viewText()
	for i = 1, self.word:length() do
		msg.post(self.cells[i], "set_letter", {letter = self.letters[i]}) 
	end
end

return WordLines