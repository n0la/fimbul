---@module fimbul.v35.damage

local damage = {}

local dice_expression = require("fimbul.dice_expression")

function damage:value()
   return self.damage
end

function damage:new(dmg, dt)
   local neu = {}
   local d

   if type(dmg) == "string" then
      neu.expression = dmg
      d = dice_expression.evaluate(dmg)
   elseif type(dmg) == "number" then
      neu.expression = tostring(dmg)
      d = dmg
   else
      error("Invalid damage type.")
   end
   local damagetype = dt or "untyped"

   setmetatable(neu, self)
   self.__index = self

   neu.damage = d
   neu.type = damagetype

   return neu
end

return damage
