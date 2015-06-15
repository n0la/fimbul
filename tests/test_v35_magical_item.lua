#!/usr/bin/env lua

local util = require("fimbul.util")
local lunit = require("lunit")

local repository = require('fimbul.repository')
local engine = require('fimbul.v35.engine')

local weapon_template = require('fimbul.v35.weapon_template')
local armor_template = require('fimbul.v35.armor_template')
local ability_template = require('fimbul.v35.ability_template')
local material_template = require('fimbul.v35.material_template')

module("test_v35_magical_item.lua", lunit.testcase, package.seeall)

local r = repository:new()

local template_longsword = {
   name = 'Longsword',
   aliases = { 'Long sword' },
   category = 'martial',
   class = 'one-handed',
   damage = {
      types = { 'slashing'},
      small = { '1d6' },
      medium = { '1d8' },
   },
   threat = { 19, 20 },
   cost = 15,
   weight = 4,
}

local template_iron = {
   name = 'Iron',
}

local template_cold_iron = {
   name = 'Cold Iron',
   hardness = '10',
   hp = '30',
   cost = {
      weapon = { multiplier = 2.0, enhancement = 2000 },
      armor = { multiplier = 2.0, enhancement = 2000 },
      shield = { multiplier = 2.0, enhancement = 2000 },
   },
}

-- Setup environment
table.insert(r.weapon, weapon_template:new(template_longsword))
table.insert(r.material, material_template:new(template_cold_iron))
table.insert(r.material, material_template:new(template_iron))
r:update_items()
r.engine = engine:new()

function test_parse_item_simple()
   local item = r:parse_item('Longsword')

   assert(item ~= nil, 'parse_item does not parse a simple weapon.')
   assert(item.slot == 'weapon', 'Item is not of the appropriate slot.')
   assert(item.material.name == 'default',
          'Item does not have the default material.')
   assert(item:price() == 15, 'Item has invalid price.')
   assert(item:is_artefact() == false, 'Item is an artefact.')
   assert(item:magic_modifier() == 0, 'Item has magic modifier.')
   assert(item:is_masterwork() == false, 'Item is mastework.')
   assert(item:weight() == 4, 'Item has invalid weight.')

   assert(item:craft_xp() == 0, 'Item requires XP to create.')
   assert(item:craft_price() == 0,
          'Item is magical and requires price to craft.')
   assert(item:craft_days() == 0, 'Item requires days to craft.')
end

function test_parse_item_masterwork()
   local item = r:parse_item('Masterwork Longsword')

   assert(item ~= nil,
          'parse_item does not parse a masterwork longsword.')
   assert(item:is_masterwork() == true,
          'Masterwork Longsword is not masterwork.')
   assert(item:price() == 315, 'Masterwork is not added to the price.')
end

-- Cold Iron is perfect. It has some unique properties, and its
-- name is similar to another material Iron, which tests the parser.
function test_parse_item_cold_iron()
   local item = r:parse_item('Cold Iron Longsword')

   assert(item ~= nil,
          'parse_item does not parse a Cold Iron Longsword')
   assert(item.material.name == 'Cold Iron',
          'Cold Iron Longsword is not made out of Cold Iron')
   assert(item:price() == 30,
          'Cold Iron Longsword does not cost double.')
end

function test_parse_item_magical_cold_iron()
   local item = r:parse_item('+2 Cold Iron Longsword')

   assert(item ~= nil,
          'parse_item does not parse a Cold Iron Longsword')
   assert(item.material.name == 'Cold Iron',
          'Cold Iron Longsword is not made out of Cold Iron')
   -- The PHB lists this as the example on how to calculate a Cold Iron
   -- weapon: A +2 Cold Iron Longsword must cost 10330 gold:
   --    8000 [modifier] (+2 modifier)
   -- +  2000 [enchantment] (extra cost due to Cold Iron for +2)
   -- +   300 [masterwork] (must be masterwork)
   -- +    30 [base] (double base price due to Cold Iron)
   -- = 10330
   assert(item:price() == 10330,
          'Cold Iron Longsword does not cost as much as PHB says.')
end
