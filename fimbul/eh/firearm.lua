---@module fimbul.eh.firearm

local firearm = {}

local base = _G

local stacked_value = require('fimbul.stacked_value')
local dice = require('fimbul.dice')
local dice_expression = require('fimbul.dice_expression')

local util = require('fimbul.util')
local rules = require('fimbul.eh.rules')
local range = require('fimbul.eh.range')

function firearm:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   self.ammunition = {}
   self._range = range:new(0)
   self.modes = {}
   self.magazine = {}
   self.recoil = 0
   self._skill = nil
   self._cost = 0
   self._weight = 0

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

   neu._range = range:new(t.range or 0)

   neu.ammunition = util.deepcopy(t.ammunition)
   neu.modes = util.deepcopy(t.modes)
   neu.magazine = util.deepcopy(t.magazine)
   neu.recoil = t.recoil or 1
   neu._cost = t.cost or 50
   neu._weight = t.weight or 0.7
   neu._skill = t.skill or 'Small Arms'

   return neu
end

function firearm:_parse_attributes(r, s)
   -- Nothing to do.
end

function firearm:range()
   return self._range
end

function firearm:cost()
   return self._cost
end

function firearm:weight()
   return self._weight
end

function firearm:caliber()
   if #self.ammunition == 0 then
      return ''
   end

   return self.ammunition[1]
end

function firearm:roll_damage(r)
   dmg = stacked_value:new({stack = true})
   local c = r:find_spawn_first(r.eh.cartridges, self:caliber())

   for _, cal in base.pairs(c:damage()) do
      local d = 'd[[' .. cal.dice .. ']]'
      local res = dice_expression.evaluate(d)

      dmg:add(res, cal.type)
   end

   return dmg
end

function firearm:has_full_auto()
   return util.contains(self.modes, 'A')
end

function firearm:magazine_cost()
   return self:cost() * rules.equipment.MAGAZINE_COST
end

function firearm:skill()
   return self._skill
end

function firearm:string(extended)
   local e = extended or false
   local s

   s = self.name .. ' [' .. table.concat(self.ammunition, ', ') .. ']'
   if e then
      s = s .. "\n"
      s = s .. "Ranges: [" .. table.concat(self:range():ranges(), ', ') .. "]\n"
      s = s .. "Weight: " .. self:weight() .. "\n"
      s = s .. "Cost: " .. self:cost() .. "\n"
      s = s .. "Recoil: " .. self.recoil .. "\n"
      s = s .. "Modes: " .. table.concat(self.modes, ', ') .. "\n"
      s = s .. "Magazine cost: " .. self:magazine_cost()
   end

   return s
end

return firearm
