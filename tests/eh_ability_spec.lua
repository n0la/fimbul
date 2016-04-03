#!/usr/bin/env lua

describe('fimbul.eh.ability',
function()
   local ability = require('fimbul.eh.ability')
   local rules = require('fimbul.eh.rules')

   describe('constructor',
   function()
      local a = ability:new()

      assert.is.truthy(a)
      assert.is.equal(a:name(), nil)
      assert.is.equal(a:short_name(), nil)

      -- Ability automatically sets rank to average.
      assert.is.equal(a:rank(), rules.abilities.AVERAGE)
      assert.is.equal(a:modifier(), 0)
   end)

   describe('rank',
   function()
      local a = ability:new("strength")

      assert.has.errors(function() a:rank(rules.abilities.LOWEST_RANK - 1) end)
      assert.has.errors(function() a:rank(rules.abilities.HIGHEST_RANK + 1) end)

      local half = rules.abilities.AVERAGE
      for i = (half * -1),half do
         local r = 5 + i

         a:rank(r)
         assert.is.equal(a:rank(), r)
      end
   end)

   describe('modifier',
   function()
      local a = ability:new("strength")

      -- Since we are setting average the modifier has to be zero.
      assert.is.equal(a:modifier(), 0)

      local half = rules.abilities.AVERAGE
      for i = (half * -1),half do
         local r = 5 + i

         a:rank(r)
         assert.is.equal(a:rank(), r)
         assert.is.equal(a:modifier(), i)
      end
   end)

   describe('cost',
   function()
      local a = ability:new("strength")

      -- The cost for an average ability has to be zero.
      assert.is.equal(a:cost(), 0)

      a:rank(4)
      assert.is.equal(a:cost(), -5)

      a:rank(6)
      assert.is.equal(a:cost(), 6)

      a:rank(8)
      assert.is.equal(a:cost(), 21)

      a:rank(3)
      assert.is.equal(a:cost(), -9)
   end)
end)
