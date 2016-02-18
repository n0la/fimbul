---@fimbul.eh.range

local range = {}

local rules = require('fimbul.eh.rules')

function range:new(value)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu._value = value or 0

   return neu
end

function range:value(v)
   if v == nil then
      return self._value
   else
      if v < 0 then
         error('Negative ranges are not allowed.')
      end
      self._value = v
   end
end

function range:ranges()
   local r = {}

   table.insert(r, self:value())
   table.insert(r, self:maximum_lower_bound())
   table.insert(r, self:far_upper_bound())
   table.insert(r, self:medium_upper_bound())
   table.insert(r, self:close_upper_bound())

   return r
end

function range:maximum_upper_bound()
   return self:value()
end

function range:maximum_lower_bound()
   return self:value() * rules.combat.range.bounds[rules.combat.range.MAXIMUM]
end

function range:far_lower_bound()
   return self:value() * rules.combat.range.bounds[rules.combat.range.FAR]
end

function range:far_upper_bound()
   return self:maximum_lower_bound()
end

function range:medium_lower_bound()
   return self:value() * rules.combat.range.bounds[rules.combat.range.MEDIUM]
end

function range:medium_upper_bound()
   return self:far_lower_bound()
end

function range:close_lower_bound()
   return self:value() * rules.combat.range.bounds[rules.combat.range.CLOSE]
end

function range:close_upper_bound()
   return self:medium_lower_bound()
end

function range:determine(v)
   if v >= self:close_lower_bound() and v <= self:close_upper_bound() then
      return rules.combat.range.CLOSE
   elseif v > self:close_upper_bound() and v <= self:medium_upper_bound() then
      return rules.combat.range.MEDIUM
   elseif v > self:medium_upper_bound() and v <= self:far_upper_bound() then
      return rules.combat.range.FAR
   elseif v > self:far_upper_bound() and v <= self:maximum_upper_bound() then
      return rules.combat.range.MAXIMUM
   elseif v > self:maximium_upper_bound() then
      return rules.combat.range.OUTOF
   end

   return nil
end

return range
