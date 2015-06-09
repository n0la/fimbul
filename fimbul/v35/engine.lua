--- @module fimbul.v35.engine

local engine = {}
package.loaded["fimbul.v35.engine"] = engine

local base = _G
local util = require("fimbul.util")

local logger = require("fimbul.logger")
local stacked_value = require("fimbul.stacked_value")

local monster = require("fimbul.v35.monster")
local encounter = require("fimbul.v35.encounter")
local character = require("fimbul.v35.character")

local battle = require("fimbul.v35.battle")
local rules = require("fimbul.v35.rules")
local damage = require("fimbul.v35.damage")

local item = require("fimbul.v35.item")
local weapon = require("fimbul.v35.weapon")

local monster_template = require("fimbul.v35.monster_template")
local encounter_template = require("fimbul.v35.encounter_template")
local character_template = require("fimbul.v35.character_template")
local weapon_template = require("fimbul.v35.weapon_template")

function engine.stacked_value(c)
   -- Compose a new stacked value with proper v35 rules
   -- in place. Mostly regarding dodge and circumstance
   return stacked_value.new(c or stacked_value, rules.stacking_rules)
end

function engine.damage(expr, t)
   local err, d = pcall(damage.new, damage, expr, t)
   return err, d
end

function engine:create_template(what, ...)
   if what == "monster_template" then
      return monster_template:new(...)
   elseif what == "encounter_template" then
      return encounter_template:new(...)
   elseif what == "character_template" then
      return character_template:new(...)
   elseif what == "weapon_template" then
      return weapon_template:new(...)
   else
      error("Unsupported template in v35: " .. what)
   end
end

function engine:spawn(repository, template)
   if template.templatetype == "monster" then
      return monster:spawn(repository, template)
   elseif template.templatetype == "encounter" then
      return encounter:spawn(repository, template)
   elseif template.templatetype == "character" then
      return character:spawn(repository, template)
   elseif template.templatetype == "weapon" then
      return weapon:spawn(repository, template)
   else
      logger.critical("Unsupported spawnable in v35: " .. template.templatetype)
   end
end

function engine:create_battle(template, characters)
   return battle:new(template, characters)
end

function engine:_find_item_and_spawn(r, s)
   local items = r:find("items", s)

   if items == nil or #items == 0 or #items > 1 then
      return nil
   end

   local it = r:spawn(items[1])
   return it
end

function engine:parse_item(r, s)
   local parts = util.split(s)

   for i = 1, #parts do
      local w = parts[i]
      local it = self:_find_item_and_spawn(r, w)

      if it then
         table.remove(parts, i)
         it:_parse_attributes(r, util.join(parts))
         return it
      end
   end

   for i = 1, #parts - 1 do
      local w = parts[i] .. ' ' .. parts[i+1]
      local it = self:_find_item_and_spawn(r, w)

      if it then
         table.remove(parts, i)
         table.remove(parts, i+1)
         it:_parse_attributes(r, util.join(parts))
         return it
      end
   end

   return nil
end

function engine:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

return engine
