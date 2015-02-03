#!/usr/bin/env lua

-- Unit test for stacked value

local stacked_value = require("fimbul.stacked_value")
local lunit = require("lunit")
local pretty = require("pl.pretty")

module("test_stacked_value", lunit.testcase, package.seeall)

function test_construction()
   local s = stacked_value:new()

   assert(s, "no object created")
   assert(s.values, "stacked_value has nil table of values")
   assert(s.rules, "stacked_value has nil table of rules")

   assert(s.rules.stack ~= nil, "stacked_value has no default rule")
   lunit.assert_false(s.rules.stack,
                      "stacked_value default rule is wrong, must be 'false'")
end

function test_construction_rules()
   local s = stacked_value:new({stack = stacked_value.STACK,
                                dodge = stacked_value.DONT_STACK})

   assert(s, "no object created")
   assert(s.rules, "no rules object in method")
   assert(s.rules.stack == stacked_value.STACK,
          "default rule is wrong, must be 'true'")
   assert(s.rules.dodge == stacked_value.DONT_STACK,
          "dodge stacking rule is not 'false'")
end

function test_stacking_rule_normal()
   local s = stacked_value:new({stack = stacked_value.STACK,
                                dodge = stacked_value.DONT_STACK})

   assert(s:stacking_rule() == stacked_value.STACK,
          "does not return default stacking rule if passed 'nil'")
   assert(s:stacking_rule("dodge") == stacked_value.DONT_STACK,
          "does not return proper stacking rule")
end

function test_stacking_rule_default()
   local s = stacked_value:new({stack = stacked_value.STACK,
                                dodge = stacked_value.DONT_STACK})

   assert(s:stacking_rule("base") == stacked_value.STACK,
          "does not return default stacking rule for unknown types")
end

function test_value_default()
   local s = stacked_value:new()

   assert(s:value() == 0, "empty object returned non-zero for value()")
end

function test_value_add()
   local s = stacked_value:new()

   assert(s:count() == 0, "new object is not empty")

   s:add(4, "enhancement")
   s:add(4, "enhancement")

   assert(s:count() == 2, "object loses values of the same type")
end

function test_value_default()
   local s = stacked_value:new()

   s:add(4, "enhancement")
   s:add(4, "enhancement")
   s:add(4, "enhancement")

   assert(s:count() == 3, "items were not properly added")
   assert(s:value() == 4, "does not adhere to default stacking values")
end

function test_value_stack1()
   local s = stacked_value:new({stack = stacked_value.STACK})

   s:add(4, "enhancement")
   s:add(3, "enhancement")
   s:add(2, "enhancement")

   assert(s:count() == 3, "items were not properly added")
   assert(s:value() == 9, "does not properly stack")
end

function test_value_stack2()
   local s = stacked_value:new({stack = stacked_value.DONT_STACK})

   s:add(4, "enhancement")
   s:add(3, "dodge")
   s:add(2, "enhancement")

   assert(s:count() == 3, "items were not properly added")
   assert(s:value() == 7, "does not properly stack")
end

function test_value_stack3()
   local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                dodge = stacked_value.STACK})

   s:add(4, "enhancement")
   s:add(3, "dodge")
   s:add(2, "enhancement")
   s:add(1, "dodge")
   s:add(1, "dodge")

   assert(s:count() == 4, "items were not properly added")
   assert(s:value() == 9, "does not properly stack")
end

function test_value_stack3()
   local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                dodge = stacked_value.DIFFERENT_VALUES})

   s:add(4, "enhancement")
   s:add(3, "dodge")
   s:add(2, "enhancement")
   s:add(1, "dodge")
   s:add(1, "dodge")

   assert(s:count() == 5, "items were not properly added")
   assert(s:value() == 8, "does not properly stack")
end

function test_value_stack3()
   local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                dodge = stacked_value.DIFFERENT_VALUES})

   s:add(4, "enhancement")
   s:add(3, "dodge")
   s:add(2, "enhancement")
   s:add(1, "dodge")
   -- The following two should not stack
   s:add(1, "dodge")
   s:add(3, "dodge")

   assert(s:count() == 6, "items were not properly added")
   assert(s:value() == 8, "does not properly stack")
end

function test_value_remove_all()
   local s = stacked_value:new({stack = stacked_value.DONT_STACK,
                                dodge = stacked_value.DIFFERENT_VALUES})

   s:add(4, "enhancement")
   s:add(3, "dodge")
   s:add(2, "enhancement")
   s:add(1, "dodge")
   -- The following two should not stack
   s:add(1, "dodge")
   s:add(3, "dodge")

   assert(s:count() == 6, "items were not properly added")
   assert(s:value() == 8, "does not properly stack")

   s:remove_all(1, "dodge")

   assert(s:count() == 4, "items were not properly removed")
   assert(s:value() == 7, "items do not properly stack")
end
