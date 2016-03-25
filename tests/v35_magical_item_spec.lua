#!/usr/bin/env lua

describe('fimbul.v35.magical_item',
function()

   local util = require("fimbul.util")

   local repository = require('fimbul.repository')
   local engine = require('fimbul.v35.engine')

   local weapon_template = require('fimbul.v35.weapon_template')
   local armor_template = require('fimbul.v35.armor_template')
   local ability_template = require('fimbul.v35.ability_template')
   local material_template = require('fimbul.v35.material_template')

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
   e = engine:new()
   r:engine(e)
   table.insert(r.weapon, weapon_template:new(template_longsword))
   table.insert(r.material, material_template:new(template_cold_iron))
   table.insert(r.material, material_template:new(template_iron))
   e:update_items(r)

   describe('parse_item_simple',
   function()
      local item = r:parse_item('Longsword')

      assert.are_not.equal(item, nil)
      assert.is.equal(item.slot, 'weapon')
      assert.is.equal(item.material.name, 'default')
      assert.is.equal(item:price(), 15)
      assert.is.equal(item:is_artifact(), false)
      assert.is.equal(item:magic_modifier(), 0)
      assert.is.equal(item:is_masterwork(), false)
      assert.is.equal(item:weight(), 4)

      assert.is.equal(item:craft_xp(), 0)
      assert.is.equal(item:craft_price(), 0)
      assert.is.equal(item:craft_days(), 0)
   end)

   describe('parse_item_masterwork',
   function()
      local item = r:parse_item('Masterwork Longsword')

      assert.are_not.equal(item, nil)
      assert.is.equal(item:is_masterwork(), true)
      assert.is.equal(item:price(), 315)
   end)

   describe('parse_item_cold_iron',
   function()
      -- Cold Iron is perfect. It has some unique properties, and its
      -- name is similar to another material Iron, which tests the parser.
      local item = r:parse_item('Cold Iron Longsword')

      assert.are_not.equal(item, nil)
      assert.is.equal(item.material.name, 'Cold Iron')
      assert.is.equal(item:price(), 30)
   end)

   describe('parse_item_cold_iron_longsword',
   function()
      local item = r:parse_item('+2 Cold Iron Longsword')

      assert.are_not.equal(item, nil)
      assert.is.equal(item.material.name, 'Cold Iron')
      --
      -- The PHB lists this as the example on how to calculate a Cold Iron
      -- weapon: A +2 Cold Iron Longsword must cost 10330 gold:
      --    8000 [modifier] (+2 modifier)
      -- +  2000 [enchantment] (extra cost due to Cold Iron for +2)
      -- +   300 [masterwork] (must be masterwork)
      -- +    30 [base] (double base price due to Cold Iron)
      -- = 10330
      --
      assert.is.equal(item:price(), 10330)
   end)
end)
