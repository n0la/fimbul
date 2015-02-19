---@module fimbul.v35.battle

local battle = {}

local base = _G
local table = require("table")

local battle_logger = require("fimbul.battle_logger")
local util = require("fimbul.util")

function battle:_update()
   -- Sort monster template based on initiative
   table.sort(self.members,
              function (m1, m2)
                 return m1.initiative > m2.initiative
              end)
end

function battle:has_started()
   return self.round > 0
end

function battle:current_round()
   return self.round
end

function battle:is_wipe()
   local w = true

   -- Is the whole battle a wipe?
   util.foreach(self.members, function (m)
                   if m:is_alive() then
                      w = false
                   end
   end)
end

function battle:next()
   if not self:has_started() then
      return
   end

   if self:is_wipe() then
      return nil
   end

   local newround = false
   local target

   repeat
      self.current = self.current + 1
      if self.current >= #self.members then
         self.current = 1
         self.round = self.round + 1
         newround = true

         self.logger:emit("New round #%d has started.", self.round)
      end

      target = self.members[self.current]
   until target:is_alive()

   self.currentmember = target
   self.logger:emit("%s's turn has started.", util.getname(target))

   return newround, target
end

function battle:start()
   if self:has_started() then
      return
   end

   -- Roll iniative for monsters
   util.foreach(self.monsters, function(m) m:roll_initiative() end)
   -- Resort list
   self:_update()

   -- Mark as started.
   self.round = 1
   self.current = 0
   self.currentmember = self.monsters[1]

   self.logger:emit("Battle started.")

   self:next()
end

function battle:damage(target, damage, source)
   if source == nil then
      damage.source = self.currentmember
   else
      damage.source = source
   end
   damage.target = target
   if target:is_healed_by(damage.type) then
      self.logger:emit("%s healed %s for %s points of damage.",
                       util.getname(damage.source), util.getname(damage.target),
                       damage:value())
      target:heal(damage)
   else
      -- Previously dead?
      local dead = target:is_dead()
      self.logger:emit("%s damaged %s for %s points of damage.",
                       util.getname(damage.source), util.getname(damage.target),
                       damage:value())
      target:damage(damage)

      if target:is_dead() and not dead then
         self.logger:emit("%s died.", util.getname(damage.target))
      end
   end
   -- TODO: Battle logger
end

function battle:new(encounter, characters)
   local neu = {}

   assert(encounter, "An encounter must be passed.")
   assert(characters, "No players specified.")

   setmetatable(neu, self)
   self.__index = self

   -- Logger
   neu.logger = battle_logger:new()
   -- Keep it for reference
   neu.encounter = encounter
   -- Copy monsters over. We may need them separatedly
   neu.monsters = encounter.monsters
   -- Create a list of all members
   neu.members = util.concat_table({}, neu.monsters)
   neu.members = util.concat_table(neu.members, characters)

   -- Round zero (aka not yet started)
   neu.round = 0
   neu.current = 0
   neu.currentmember = {}

   neu:_update()

   return neu
end

return battle
