--- @module fimbul.v35.creature

local dice_expression = require("fimbul.dice_expression")

local attributes = require("fimbul.v35.attributes")
local saves = require("fimbul.v35.saves")
local engine = require("fimbul.v35.engine")

local creature = {}

function creature:new()
   local neu = {}

   setmetatable(neu, self)
   neu.__index = self

   neu.name = ""
   neu.hd = 0
   neu.bab = 0

   -- Current hit points and maximum hit points
   neu.hp = 0
   neu.max_hp = 0
   neu.temp_hp = 0

   -- TODO: Warrants its own class
   neu.ac = engine:stacked_value()
   neu.saves = saves:new()
   neu.attributes = attributes:new()

   neu.size = "medium"
   neu.grapple = 0
   neu.speed = 30
   neu.space = 5
   neu.reach = 5
   neu.initiative = 0
end

function creature:spawn(t)
   local neu = creature:new()
   local template = t or self.template

   if template == nil then
      error("No template specified to spawn from.")
   end

   if not template.name then
      error("The template should at least specify a name.")
   end

   if not template.hd then
      error("The template does not specify hit dice.")
   end

   local hp = dice_expression(template.hd)

   neu.name = template.name
   neu.hd = template.hd

   -- Hit points
   neu.hp = hp
   neu.max_hp = hp

   neu.ac:load(template.ac)
   neu.saves:load(template.saves)
   neu.attributes:load(template.attributes)

   neu.initiative = template.initiative or 0
   neu.bab = template.bab or 0

   neu.size = template.size or "medium"
   neu.grapple = template.grapple or 0
   neu.speed = template.speed or 30
   neu.space = template.space or 5
   neu.reach = template.reach or 5

   neu.template = template

   return neu
end

return creature
