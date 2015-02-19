---@module fimbul.battle_logger

local battle_logger = {}

local string = require("string")
local table = require("table")

function battle_logger:handler(F, a)
   self.handler = { func = F, arg = a}
end

function battle_logger:emit(s, ...)
   local s = string.format(s, ...)
   table.insert(self.buffer, s)
   if self.handler ~= nil and self.handler.func ~= nil then
      self.handler.func(self.handler.arg, s)
   end
end

function battle_logger:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.buffer = {}

   return neu
end

return battle_logger
