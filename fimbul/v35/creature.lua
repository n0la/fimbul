--- @module fimbul.v35.creature

local dice_expression = require("fimbul.dice_expression")

local base = _G

local rules = require("fimbul.v35.rules")
local attributes = require("fimbul.v35.attributes")
local armour_class = require("fimbul.v35.armour_class")
local saves = require("fimbul.v35.saves")
local dice = require("fimbul.dice")
local string = require("string")

local creature = {}

function creature:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.name = ""
   neu.type = ""
   neu.hd = 0
   neu.bab = 0

   -- Current hit points and maximum hit points
   neu.hp = 0
   neu.max_hp = 0
   neu.temp_hp = 0

   neu.ac = armour_class:new()
   neu.saves = saves:new()
   neu.attributes = attributes:new()

   neu.size = "medium"
   neu.grapple = 0
   neu.speed = 30
   neu.space = 5
   neu.reach = 5
   neu.initiative = 0
   neu.cr = 1

   return neu
end

function creature:spawn(r, t)
   local neu = self:new()
   local template = t or self.template

   if template == nil then
      error("No template specified to spawn from.")
   end

   if not template.name then
      error("The template should at least specify a name.")
   end

   local hp = dice_expression.evaluate(template.hd or "1")

   neu.name = template.name
   neu.type = template.type
   neu.hd = template.hd

   -- Hit points
   neu.hp = hp
   neu.max_hp = hp

   neu.ac:load(template.ac)
   neu.saves:load(template.saves)
   neu.attributes:load(template.attributes)

   neu.bab = template.bab or 0

   neu.size = template.size or "medium"
   neu.grapple = template.grapple or 0
   neu.speed = template.speed or 30
   neu.space = template.space or 5
   neu.reach = template.reach or 5
   neu.cr = template.cr or 1

   neu.template = template

   return neu
end

function creature:roll_initiative()
   self.initiative = dice.d20:roll() + (self.template.initiative or 0)
end

function creature:is_dead()
   return self.hp <= -10
end

function creature:is_dying()
   -- TODO: House rule
   return self.hp > -10 and self.hp < 0
end

function creature:is_unconsious()
   return self.hp == 0
end

function creature:is_alive()
   return self.hp > 0
end

function creature:is_undead()
   return string.lower(self.type) == "undead"
end

function creature:is_healed_by(dt)
   if self:is_undead() then
      return dt == rules.damage_types.NEGATIVE
   else
      return dt == rules.damage_types.POSITIVE
   end
end

function creature:heal(v)
   local neu

   neu = self.hp + v:value()
   if neu > self.max_hp then
      neu = self.max_hp
   end
   self.hp = neu
end

function creature:damage(v)
   local neu

   neu = self.hp - v:value()
   self.hp = neu
end

function creature:set(variable, value)
   if variable == nil or value == nil then
      error('variable and value must be set')
   end

   if self[variable] == nil then
      error('No such variable.')
   end

   local old = self[variable]
   local try = base.tonumber(value)

   if try ~= nil and value ~= nil then
      self[variable] = try
   else
      self[variable] = value
   end

   return old
end

function creature:get(variable)
   if variable ~= nil then
      return nil
   end

   return self[variable]
end

return creature
