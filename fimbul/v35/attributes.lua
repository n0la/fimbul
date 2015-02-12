--- @module fimbul.v35.attributes

local attributes = {}
package.loaded["fimbul.v35.attributes"] = attributes

local attribute = require("fimbul.v35.attribute")

function attributes:load(o)
end

function attributes:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.strength = attribute:new("strength")
   neu.dexterity = attribute:new("dexterity")
   neu.constitution = attribute:new("constitution")
   neu.intelligence = attribute:new("intelligence")
   neu.wisdom = attribute:new("wisdom")
   neu.charisma = attribute:new("charisma")

   return neu
end

return attributes
