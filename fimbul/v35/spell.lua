--- @module fimbul.v35.spell

local base = _G

local util = require('fimbul.util')

local spell = {}

function spell:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function spell:spawn(r, t)
   local neu = spell:new()

   neu.name = t.name

   neu.components = {}
   neu.components.arcanefocus = t.components.arcanefocus or false
   neu.components.divinefocus = t.components.divinefocus or false
   neu.components.material = t.components.material or 0
   neu.components.somatic = t.components.somatic or false
   neu.components.verbal = t.components.verbal or false
   neu.components.xp = t.components.xp or 0
   neu.components.gold = t.components.gold or 0

   neu.description = t.description or ''

   neu._domains = util.deepcopy(t.domains or {})
   neu._levels = util.deepcopy(t.levels or {})

   neu.duration = t.duration or ''
   neu.effect = t.effect or ''
   neu.range = t.range or ''
   neu.savingthrow = t.savingthrow or ''
   neu.school = t.school or ''
   neu.spellresistance = t.spellresistance or false
   neu.target = t.target or ''

   return neu
end

function spell:levels()
   return self._levels or {}
end

return spell
