--- @module fimbul.v35.encounter

local base = _G

local dice_expression = require("fimbul.dice_expression")
local creature = require("fimbul.v35.creature")
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
   neu.players = {}

   return neu
end

function encounter:spawn(r, encounter)
   local neu = self:new()
   local e = encounter

   if type(encounter) == "string" then
      e = r:find("encounters", encounter)
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
      for i = 0, a do
         local template = r:find("monster", t)

         if #template == 0 then
            error("Encounter " .. neu.name .. " uses monster " ..
                     t .. " which cannot be found.")
         elseif #template > 1 then
            error("Encounter " .. neu.name .. " uses monster " ..
                     t .. " which is not unique.")
         else
            template = template[1]
         end

         local monster = creature:spawn(r, template)
         -- Change name
         monster.name = monster.name .. " " .. (i+1)
         table.insert(neu.monsters, monster)
      end
   end

   return neu
end

function encounter:_update()
   -- Sort monster template based on initiative
   table.sort(self.monsters,
              function (m1, m2)
                 return m1.initiative > m2.initiative
   end)
end

function encounter:start()
   -- Roll iniative
   util.foreach(self.monsters, function(m) m:roll_initiative() end)
   self:_update()
end

return encounter
