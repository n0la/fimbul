---@module fimbul.eh.firearm

local firearm = {}

local util = require('fimbul.util')
local rules = require('fimbul.eh.rules')

function firearm:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   self.ammunition = {}
   self.range = 0
   self.modes = {}
   self.magazine = {}
   self.recoil = 0
   self.cost = 0
   self.weight = 0

   return neu
end

function firearm:spawn(r, t)
   local neu = self:new()

   if not t.name then
      error('Firearm should have a name')
   end

   neu.name = t.name
   neu.template = t

   neu.aliases = util.deepcopy(t.aliases or {})

   neu.ammunition = util.deepcopy(t.ammunition)
   neu.range = t.range or 50
   neu.modes = util.deepcopy(t.modes)
   neu.magazine = util.deepcopy(t.magazine)
   neu.recoil = t.recoil or 1
   neu.cost = t.cost or 50
   neu.weight = t.weight or 0.7

   return neu
end

function firearm:_parse_attribute(r, s)
   -- Nothing to do.
end

function firearm:caliber()
   if #self.ammunition == 0 then
      return ''
   end

   return self.ammunition[1]
end

function firearm:has_full_auto()
   return util.contains(self.modes, 'A')
end

function firearm:magazine_cost()
   return self.cost * rules.equipment.MAGAZINE_COST
end

function firearm:string(extended)
   local e = extended or false
   local s

   s = self.name .. ' [' .. table.concat(self.ammunition, ', ') .. ']'
   if e then
      s = s .. "\n"
      s = s .. "Weight: " .. self.weight .. "\n"
      s = s .. "Cost: " .. self.cost .. "\n"
      s = s .. "Recoil: " .. self.recoil .. "\n"
      s = s .. "Modes: " .. table.concat(self.modes, ', ') .. "\n"
      s = s .. "Magazine cost: " .. self:magazine_cost() .. "\n"
   end

   return s
end

return firearm
