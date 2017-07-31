--- @module fimbul.v35.engine

local engine = {}
package.loaded["fimbul.v35.engine"] = engine

local base = _G
local util = require("fimbul.util")

local pretty = require("pl.pretty")

local logger = require("fimbul.logger")
local stacked_value = require("fimbul.stacked_value")

local spawner = require('fimbul.spawner')

local battle = require("fimbul.v35.battle")
local rules = require("fimbul.v35.rules")
local damage = require("fimbul.v35.damage")

function engine.stacked_value(c)
   return stacked_value.new(c or stacked_value, rules.stacking_rules)
end

function engine.damage(expr, t)
   local err, d = pcall(damage.new, damage, expr, t)
   return err, d
end

function engine:create_template(what, ...)
   return self._spawner:create_template(what, ...)
end

function engine:spawn(repository, template)
   return self._spawner:spawn(repository, template)
end

function engine:create_battle(template, characters)
   return battle:new(template, characters)
end

function engine:description()
   return "Engine for D&D v35 also known as d20srd."
end

function engine:init(r)
   r.v35 = {}
   r.v35.monster = {}
   r.v35.encounter = {}
   r.v35.character = {}
   r.v35.npc = {}
   r.v35.lore = {}
   r.v35.lores = {}
   r.v35.characters = {}
   r.v35.weapon = {}
   r.v35.material = {}
   r.v35.armor = {}
   r.v35.shield = {}
   r.v35.ability = {}
   r.v35.artifact = {}
   r.v35.wondrous = {}
   r.v35.spell = {}
   r.v35.wand = {}
   r.v35.items = {}
end

function engine:characters(r)
   return r.v35.characters
end

function engine:lore(r)
   return r.v35.lores
end

function engine:update_lore(r)
   local lore = {}

   lore = util.concat_table(lore, r.v35.monster)
   lore = util.concat_table(lore, r.v35.character)
   lore = util.concat_table(lore, r.v35.npc)
   lore = util.concat_table(lore, r.v35.lore)

   r.v35.lores = lore
end

function engine:update_characters(r)
   local characters = {}

   characters = util.concat_table(characters, r.v35.monster)
   characters = util.concat_table(characters, r.v35.character)
   characters = util.concat_table(characters, r.v35.npc)

   r.v35.characters = characters
end

function engine:update_items(r)
   local items = {}

   -- Add artifacts
   items = util.concat_table(items, r.v35.artifact)
   -- Add other items
   items = util.concat_table(items, r.v35.weapon)
   items = util.concat_table(items, r.v35.armor)
   items = util.concat_table(items, r.v35.shield)
   items = util.concat_table(items, r.v35.wondrous)
   items = util.concat_table(items, r.v35.wand)

   r.v35.items = items
end

function engine:load(r)
   -- PCs and NPCs
   r:_load_files("monsters", "monster_template", r.v35.monster)
   r:_load_files("characters", "character_template", r.v35.character)
   r:_load_array("characters", "character_template", r.v35.character)
   r:_load_files("npcs", "character_template", r.v35.npc)
   r:_load_array("npcs", "character_template", r.v35.npc)
   -- Load lore
   r:_load_files("lore", "lore_template", r.v35.lore)
   -- Encounters
   r:_load_files("encounters", "encounter_template", r.v35.encounter)
   -- Load spells
   r:_load_array("spells", "spell_template", r.v35.spell)
   -- Items and Gear
   r:_load_array("wands", "wand_template", r.v35.wand)
   r:_load_array("weapons", "weapon_template", r.v35.weapon)
   r:_load_array("materials", "material_template", r.v35.material)
   r:_load_array("armors", "armor_template", r.v35.armor)
   r:_load_array("shields", "shield_template", r.v35.shield)
   r:_load_array("wondrous", "wondrous_item_template", r.v35.wondrous)
   -- Special magical abilities
   r:_load_array("abilities", "ability_template", r.v35.ability)
   -- Load artifacts
   r:_load_array("artifacts", "artifact_template", r.v35.artifact)

   self:update_items(r)
   self:update_characters(r)
   self:update_lore(r)
end

function engine:_find_item_and_spawn(r, s)
   local items = r:find(r.v35.items, s)

   if items == nil or #items == 0 then
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
   spawner = function(str, tbl, pos, i)
      local item = self:_find_item_and_spawn(r, str)
      if item ~= nil and it == nil then
         t = util.shallowcopy(parts)
         util.remove(t, pos, i)
         it = item
         -- TODO: Most do split() anyhow.
         it:_parse_attributes(r, table.concat(t, " "))
         return true
      else
         return false
      end
   end

   for i = 1, #parts do
      ok = util.lookahead(parts, i, spawner)
      if ok then
         break
      end
   end

   return it
end

function engine:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu._spawner = spawner:new('fimbul.v35')
   neu._spawner:add('monster', 'encounter',
                    'character', 'weapon',
                    'material', 'armor',
                    'shield', 'ability',
                    'artifact', 'wondrous_item',
                    'spell', 'wand', 'lore'
   )

   return neu
end

return engine
