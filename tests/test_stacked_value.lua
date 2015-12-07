#!/usr/bin/env lua

describe('fimbul.stacked_value',
function()

   local stacked_value = require("fimbul.stacked_value")

   describe('constructor',
   function()
      local s = stacked_value:new()

      assert.is.truthy(s)
      assert.is.truthy(s.values)
      assert.is.truthy(s.rules)

      assert.is.equal(s.rules.stack, false)
   end)

   describe('constructor_rules',
   function()
      local s = stacked_value:new({stack = stacked_value.STACK,
                                   dodge = stacked_value.DONT_STACK})

      assert.is.equal(s.rules.stack, stacked_value.STACK)
      assert.is.equal(s.rules.dodge, stacked_value.DONT_STACK)
   end)

   describe('stacking_rule',
   function()
      local s = stacked_value:new({stack = stacked_value.STACK,
                                   dodge = stacked_value.DONT_STACK})
      assert.is.equal(s:stacking_rule(), stacked_value.STACK)
      assert.is.equal(s:stacking_rule("dodge"), stacked_value.DONT_STACK)
      -- Test whether it returns the default rule for unknown types.
      assert.is.equal(s:stacking_rule("base"), stacked_value.STACK)
   end)

   describe('value',
   function()
      local s = stacked_value:new()

      assert.is.equal(s:value(), 0)

      s:add(4, "enhancement")
      s:add(4, "enhancement")
      s:add(4, "enhancement")

      assert.is.equal(s:count(), 3)
      assert.is.equal(s:value(), 4)
   end)

   describe('value_stack',
   function()
      local s = stacked_value:new({stack = stacked_value.STACK})

      s:add(4, "enhancement")
      s:add(3, "enhancement")
      s:add(2, "enhancement")

      assert.is.equal(s:count(), 3)
      assert.is.equal(s:value(), 9)
   end)

   describe('value_dont_stack',
   function()
      local s = stacked_value:new({stack = stacked_value.DONT_STACK})

      s:add(4, "enhancement")
      s:add(3, "dodge")
      s:add(2, "enhancement")

      assert.is.equal(s:count(), 3)
      assert.is.equal(s:value(), 7)
   end)

   describe('value_some_stack_some_dont',
   function()
      local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                   dodge = stacked_value.STACK})

      s:add(4, "enhancement")
      s:add(3, "dodge")
      s:add(2, "enhancement")
      s:add(1, "dodge")
      s:add(1, "dodge")

      assert.is.equal(s:count(), 5)
      assert.is.equal(s:value(), 9)
   end)

   describe('value_stackvalues',
   function()
      local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                dodge = stacked_value.DIFFERENT_VALUES})

      s:add(4, "enhancement")
      s:add(3, "dodge")
      s:add(2, "enhancement")
      s:add(1, "dodge")
      s:add(1, "dodge")

      assert.is.equal(s:count(), 5)
      assert.is.equal(s:value(), 8)
   end)

   describe('value_stackvalues_not',
   function()
      local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                   dodge = stacked_value.DIFFERENT_VALUES})

      s:add(4, "enhancement")
      s:add(3, "dodge")
      s:add(2, "enhancement")
      s:add(1, "dodge")
      -- The following two should not stack
      s:add(1, "dodge")
      s:add(3, "dodge")

      assert.is.equal(s:count(), 6)
      assert.is.equal(s:value(), 8)
   end)

   describe('remove_all',
   function()
      local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                   dodge = stacked_value.DIFFERENT_VALUES})

      s:add(4, "enhancement")
      s:add(3, "dodge")
      s:add(2, "enhancement")
      s:add(1, "dodge")
      -- The following two should not stack
      s:add(1, "dodge")
      s:add(3, "dodge")

      assert.is.equal(s:count(), 6)
      assert.is.equal(s:value(), 8)

      s:remove_all(1, "dodge")

      assert.is.equal(s:count(), 4)
      assert.is.equal(s:value(), 7)
   end)
end)
