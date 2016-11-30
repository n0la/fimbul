--- @module fimbul.v35.encounter

local base = _G

local dice_expression = require("fimbul.dice_expression")
local monster = require("fimbul.v35.monster")
local util = require("fimbul.util")

local encounter = {}

function encounter:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.name = ""
   neu.gold = ""
   neu.chance = 0.12
   neu.monsters = {}

   return neu
end

function encounter:spawn(r, encounter)
   local neu = self:new()
   local e = encounter

   if type(encounter) == "string" then
      e = r:find(r.v35.encounters, encounter)
      if #e == 0 then
         error("No such encounter " .. encounter)
      else
         e = e[1]
      end
   end

   if not e.name then
      error("An encounter requires a name.")
   end

   if not e.monsters then
      error("An encounter without monsters is pointless.")
   end

   neu.name = e.name
   neu.gold = e.gold or "0"
   neu.chance = e.chance or 0.12

   for _, m in base.pairs(e.monsters) do
      local t = m.type
      local a = m.amount or "1"

      a = dice_expression.evaluate(a)
      for i = 1, a do
         local template = r:find(r.v35.monster, t)

         if #template == 0 then
            error("Encounter " .. neu.name .. " uses monster " ..
                     t .. " which cannot be found.")
         elseif #template > 1 then
            error("Encounter " .. neu.name .. " uses monster " ..
                     t .. " which is not unique.")
         else
            template = template[1]
         end

         local monster = monster:spawn(r, template)
         -- Change name if there is more than one
         if a > 1 then
            monster.name = monster.name .. " " .. i
         end
         table.insert(neu.monsters, monster)
      end
   end

   return neu
end

return encounter
