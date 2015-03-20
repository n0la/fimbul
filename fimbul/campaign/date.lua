---@module fimbul.campaign.date

local date = {}

local string = require("string")
local math = require("math")

local util = require("fimbul.util")

function date:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function date:tostring()
   return string.format("%02d.%02d.%s%d",
                        self.day, self.month, self.era, self.year)
end

return date
