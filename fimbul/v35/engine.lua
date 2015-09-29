--- @module fimbul.v35.engine

local engine = {}
package.loaded["fimbul.v35.engine"] = engine

local base = _G
local util = require("fimbul.util")

local pretty = require("pl.pretty")

local logger = require("fimbul.logger")
local stacked_value = require("fimbul.stacked_value")

local monster = require("fimbul.v35.monster")
local encounter = require("fimbul.v35.encounter")
local character = require("fimbul.v35.character")

local battle = require("fimbul.v35.battle")
local rules = require("fimbul.v35.rules")
local damage = require("fimbul.v35.damage")

local item = require("fimbul.v35.item")
local artifact = require("fimbul.v35.artifact")
local wondrous_item = require("fimbul.v35.wondrous_item")
local weapon = require("fimbul.v35.weapon")
local armor = require("fimbul.v35.armor")
local shield = require("fimbul.v35.shield")
local material = require("fimbul.v35.material")
local ability = require("fimbul.v35.ability")

local monster_template = require("fimbul.v35.monster_template")
local encounter_template = require("fimbul.v35.encounter_template")
local character_template = require("fimbul.v35.character_template")
local artifact_template = require("fimbul.v35.artifact_template")
local weapon_template = require("fimbul.v35.weapon_template")
local armor_template = require("fimbul.v35.armor_template")
local shield_template = require("fimbul.v35.shield_template")
local material_template = require("fimbul.v35.material_template")
local ability_template = require("fimbul.v35.ability_template")
local wondrous_item_template = require("fimbul.v35.wondrous_item_template")

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
   elseif what == "material_template" then
      return material_template:new(...)
   elseif what == 'armor_template' then
      return armor_template:new(...)
   elseif what == 'shield_template' then
      return shield_template:new(...)
   elseif what == 'ability_template' then
      return ability_template:new(...)
   elseif what == 'artifact_template' then
      return artifact_template:new(...)
   elseif what == 'wondrous_item_template' then
      return wondrous_item_template:new(...)
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
   elseif template.templatetype == "material" then
      return material:spawn(repository, template)
   elseif template.templatetype == "armor" then
      return armor:spawn(repository, template)
   elseif template.templatetype == "shield" then
      return shield:spawn(repository, template)
   elseif template.templatetype == "ability" then
      return ability:spawn(repository, template)
   elseif template.templatetype == "artifact" then
      return artifact:spawn(repository, template)
   elseif template.templatetype == "wondrous_item" then
      return wondrous_item:spawn(repository, template)
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

   if #parts == 0 then
      return nil
   end

   it = nil

   -- Function that will check if a given string is a valid item.
   --
   spawner = function(str, pos, i)
      local item = self:_find_item_and_spawn(r, str)
      if item ~= nil and it == nil then
         t = util.shallowcopy(parts)
         util.remove(t, pos, i)
         it = item
         it:_parse_attributes(r, table.concat(t, " "))
         return true
      else
         return false
      end
   end

   for i = 1, #parts do
      ok, str = util.lookahead(parts, i, spawner)
   end

   return it
end

function engine:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

return engine
