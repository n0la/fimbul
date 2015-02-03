--- @module fimbul.v35.attributes

local attribute = require("fimbul.v35.attribute")

local attributes = {}

function attributes:new()
   local neu = {}

   setmetatable(neu, self)
   neu.__index = self

   neu.strength = attribute.new("strength")
   neu.dexterity = attribute.new("dexterity")
   neu.constitution = attribute.new("constitution")
   neu.intelligence = attribute.new("intelligence")
   neu.wisdom = attribute.new("wisdom")
   neu.charisma = attribute.new("charisma")

   return neu
end

return attributes
