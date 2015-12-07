#!/usr/bin/env lua

describe('fimbul.eh.skill',
function()
   local skill = require('fimbul.eh.skill')
   local rules = require('fimbul.eh.rules')

   describe('constructor',
   function()
      local s = skill:new()

      assert.is_truthy(s)
      assert.is_nil(s.name)

      -- Check default values for empty skills
      assert.is_equal(s:rank(), 0)
      assert.is_equal(s:is_special(), false)
      assert.is_equal(s:is_speciality(), false)
      assert.is_nil(s:parent_skill())
      assert.is_equal(s:activated(), false)
      assert.is_equal(s:cost(), 0)
   end)

   describe('rank',
   function()
      local s = skill:new()

      s:rank(rules.skills.LOWEST_RANK)
      assert.is_equal(s:rank(), rules.skills.LOWEST_RANK)
      s:rank(rules.skills.HIGHEST_RANK)
      assert.is_equal(s:rank(), rules.skills.HIGHEST_RANK)

      assert.has.errors(function() s:rank(rules.skills.LOWEST_RANK - 1) end)
      assert.has.errors(function() s:rank(rules.skills.HIGHEST_RANK + 1) end)
   end)

   describe('activated',
   function()
      local s = skill:new()

      s:rank(1)
      assert.is_equal(s:activated(), true)
      s:rank(0)
      assert.is_equal(s:activated(), false)
   end)

   describe('cost',
   function()
      local s = skill:new()

      s:rank(1)
      -- Activation cost (non-special) + 1
      assert.is_equal(s:cost(), rules.skills.ACTIVATION_COST + 1)

      s:rank(5)
      assert.is_equal(s:cost(), rules.skills.ACTIVATION_COST + 1+2+3+4+5)

      s:rank(0)
      assert.is_equal(s:cost(), 0)
   end)

   describe('parent',
   function()
      local s = skill:new()

      assert.is_equal(s:is_speciality(), false)

      s:speciality_of(skill:new())
      assert.is_equal(s:is_speciality(), true)
   end)
end)
