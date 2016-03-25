#!/usr/bin/env lua

describe('fimbul.v35.engine',
function()
   local attribute = require("fimbul.v35.attribute")

   describe('constructor',
   function()
      local a = attribute:new()

      assert.are_not.equal(a, nil)

      assert.is.equal(a:value(), 0)
      assert.is.equal(a:count(), 0)
      assert.is.equal(a:modifier(), -5)
   end)

   describe('rules',
   function()
      local a = attribute:new()

      assert.are_not.equal(a, nil)
      assert.is.equal(a:stacking_rule("dodge"), true)
   end)

   describe('modifier',
   function()
      local a = attribute:new()

      a:add(10, "base")
      assert.is.equal(a:modifier(), 0)

      a:add(6, "enhancement")
      assert.is.equal(a:modifier(), 3)

      a:add(5, "level")
      assert.is.equal(a:modifier(), 5)

      a:add(3, "inherent")
      assert.is.equal(a:value(), 24)
      assert.is.equal(a:modifier(), 7)

      a:add(-2, "race")
      assert.is.equal(a:value(), 22)
      assert.is.equal(a:modifier(), 6)
   end)
end)
