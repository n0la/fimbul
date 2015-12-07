#!/usr/bin/env lua

describe('test_v35_attributes',
function()

   local attributes = require("fimbul.v35.attributes")

   function test_attribute(a, name)
      assert.are_not.equal(a, nil)
      assert.is.equal(a:value(), 0)
      assert.is.equal(a:modifier(), -5)
   end

   describe('constructor',
   function()
      local a = attributes:new()

      assert.are_not.equal(a, nil)

      test_attribute(a.strength, "strength")
      test_attribute(a.dexterity, "dexterity")
      test_attribute(a.constitution, "constitution")
      test_attribute(a.intelligence, "intelligence")
      test_attribute(a.wisdom, "wisdom")
      test_attribute(a.charisma, "charisma")
   end)
end)
