---@fimbul.eh.range

local range = {}

local rules = require('fimbul.eh.rules')

function range:new(value)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu._value = value

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

function range:maximum_lower_bound()
   return self:value() * rules.combat.range[rules.combat.MAXIMUM_RANGE]
end

function range:far_upper_bound()
   return self:value() * rules.combat.range[rules.combat.FAR_RANGE]
end

function range:medium_upper_bound()
   return self:value() * rules.combat.range[rules.combat.MEDIUM_RANGE]
end

function range:close_upper_bound()
   return self:value() * rules.combat.range[rules.combat.CLOSE_RANGE]
end

function range:is_maximum_range(value)
   return value >= self:maximum_range()
end

function range:determine(v)
   if v <= self:close_upper_bound() then
      return rules.combat.CLOSE_RANGE
   elseif v > self:close_upper_bound() and v <= self:medium_upper_bound() then
      return rules.combat.MEDIUM_RANGE
   elseif v > self:medium_upper_bound() and v <= self:far_upper_bound() then
      return rules.combat.FAR_RANGE
   elseif v > self:far_upper_bound() and v <= self:value() then
      return rules.combat.MAXIMUM_RANGE
   elseif v > self:value() then
      return rules.combat.OUTOF_RANGE
   end

   return nil
end

return range
