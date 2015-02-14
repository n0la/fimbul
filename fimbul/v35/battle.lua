---@module fimbul.v35.battle

local battle = {}

local base = _G
local table = require("table")
local util = require("fimbul.util")

local pretty = require("pl.pretty")

function battle:_update()
   -- Sort monster template based on initiative
   table.sort(self.members,
              function (m1, m2)
                 return m1.initiative > m2.initiative
              end)
end

function battle:start()
   if self.round > 0 then
      return
   end

   -- Roll iniative for monsters
   util.foreach(self.monsters, function(m) m:roll_initiative() end)
   -- Resort list
   self:_update()

   -- Mark as started.
   self.round = 1
end

function battle:new(encounter, characters)
   local neu = {}

   assert(encounter, "An encounter must be passed.")
   assert(characters, "No players specified.")

   setmetatable(neu, self)
   self.__index = self

   -- Keep it for reference
   neu.encounter = encounter
   -- Copy monsters over. We may need them separatedly
   neu.monsters = encounter.monsters
   -- Create a list of all members
   neu.members = util.concat_table(neu.monsters, characters)

   -- Round zero (aka not yet started)
   neu.round = 0

   neu:_update()

   return neu
end

return battle
