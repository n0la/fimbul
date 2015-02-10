--- @module fimbul.dice

local base = _G
local os = require("os")
local io = require("io")
local mm = require("math")
local string = require("string")
local table = require("table")

local random_seed = require("fimbul.randomseed")
local dice_results = require("fimbul.dice_results")
local dice_result = require("fimbul.dice_result")

local dice = {}

function dice:needs_reroll(number)
   if not self.reroll or not number then
      return false
   end

   for _,r in base.ipairs(self.reroll) do
      if tonumber(r) == tonumber(number) then
         return true
      end
   end

   return false
end

function dice:roll()
   local i = 1
   local results = dice_results:new()
   local r = 0

   random_seed.init()

   while i <= self.amount do
      local sides = self.sides or 6

      if self:is_fudge() then
         sides = 6
      end

      local tmp = mm.random(1, sides)

      if self:is_fudge() then
         tmp = self:translate_fudge(tmp)
      end

      local res = dice_result:new(tmp)
      -- Check for rerolls
      if self:needs_reroll(tmp) then
         res:drop()
      else
         i = i + 1
      end
      results:insert(res)
   end

   -- Do drop lowest and keep highest
   if self.drop_lowest and self.drop_lowest > 0 then
      results:drop_lowest(self.drop_lowest)
   end

   if self.keep_highest and self.keep_highest > 0 then
      results:keep_highest(self.keep_highest)
   end

   return results:evaluate(), results
end

function dice:is_fudge()
   return self.sides and (self.sides == "f" or self.sides == "F")
end

function dice:translate_fudge(value)
   local translate = { -1, -1, 0, 0, 1, 1 }

   value = tonumber(value)
   if value < 1 or value > 6 then
      return
   end

   return translate[value]
end

function dice:__tostring()
   local str = string.format("%dd%s", self.amount, tostring(self.sides))

   if self.keep_highest and self.keep_highest > 0 then
      str = str .. string.format("k%d", self.keep_highest)
   end

   if self.drop_lowest and self.drop_lowest > 0 then
      str = str .. string.format("d%d", self.drop_lowest)
   end

   for _,r in base.ipairs(self.reroll) do
      str = str .. string.format("r%d", tonumber(r))
   end

   return str
end

function dice:new(values)
   local neu = {}
   local o = values or {}

   setmetatable(neu, self)
   self.__index = self

   neu.amount = o.amount or 1
   neu.sides = o.sides or 6
   neu.reroll = o.amount or {}
   neu.drop_lowest = o.drop_lowest or 0
   neu.keep_highest = o.keep_highest or 0

   return neu
end

function dice:parse(str)
   local a,s,f = string.match(str, "(%d*)d([%dfF]*)(.*)")

   -- Not defining the sides is an error
   if not s then
      return
   end

   -- If amount is not given then amount is always 1
   if not a then
      a = 1
   end

   local d = self:new()

   d.amount = base.tonumber(a) or 1
   if s == "f" or s == "F" then
      d.sides = s
   else
      d.sides = base.tonumber(s)
   end

   if f then
      local drop
      local keep

      for r in string.gmatch(f, "r(%d+)") do
         table.insert(d.reroll, tonumber(r))
      end

      drop = tonumber(string.match(f, "d(%d+)"))
      if drop and drop > 0 then
         d.drop_lowest = drop
      end

      keep = tonumber(string.match(f, "k(%d+)"))
      if keep and keep > 0 then
         d.keep_highest = keep
      end
   end

   return d
end

-- Commonly used dices in games
--
dice.d100 = dice:new({sides = 100})
dice.d20 = dice:new({sides = 20})
dice.d12 = dice:new({sides = 12})
dice.d10 = dice:new({sides = 10})
dice.d8 = dice:new({sides = 8})
dice.d6 = dice:new({sides = 6})
dice.d4 = dice:new({sides = 4})


return dice
