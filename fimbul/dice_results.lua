--- @module fimbul.dice_results

local base = _G
local string = string
local table = table

local util = require("fimbul.util")
local dice_result = require("fimbul.dice_result")

local dice_results = {}

function dice_results:insert(result)
   if tonumber(result) then
      local r = dice_result.new(result)
      table.insert(self.results, r)
   else
      table.insert(self.results, result)
   end
end

function dice_results:evaluate()
   local result = 0

   for _,r in base.ipairs(self.results) do
      result = result + r:evaluate()
   end

   return result
end

function dice_results:__tostring()
   local str = ""

   for _,r in base.ipairs(self.results) do
      str = str .. base.tostring(r) .. " + "
   end

   if str == "" then
      return str
   else
      return string.sub(str, 1, -4)
   end
end

function dice_results:amount()
   local c = 0

   for _,r in base.ipairs(self.results) do
      if r.counts then
         c = c + 1
      end
   end

   return c
end

function dice_results:drop_all()
   for _, r in base.ipairs(self.results) do
      r:drop()
   end
end

function dice_results:use_all()
   for _, r in base.ipairs(self.results) do
      r:use()
   end
end

function dice_results:drop_lowest(amount)
   local cp

   if not amount or amount <= 0 then
      return
   end

   -- Optimise: If we are supposed to drop all do that instead.
   if amount >= self:amount() then
      self:drop_all()
   end

   local compare = function (a, b)
      if not a.counts then
         return true
      elseif not b.counts then
         return false
      else
         return (a > b)
      end
   end

   for i = 1, amount do
      local index, value = util.min(self.results, compare)
      self.results[index]:drop()
   end
end

function dice_results:keep_highest(amount)
   if not amount or amount <= 0 then
      return
   end

   self:drop_lowest(self:amount() - amount)
end

function dice_results:new()
   local s = {}

   setmetatable(s, self)
   self.__index = self

   s.results = {}

   return s
end

return dice_results
