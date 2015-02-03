#!/usr/bin/env lua

-- Unit test for stacked value
module("test_v35_attribute", lunit.testcase, package.seeall)

local attribute = require("fimbul.v35.attribute")
local lunit = require("lunit")
local pretty = require("pl.pretty")

function test_construction()
   local a = attribute:new()

   assert(a, "no object was created")

   assert(a:value() == 0, "object was not properly initialised")
   assert(a:count() == 0, "object was not properly initialised")
   assert(a:modifier() == -5, "object does not properly calculate modifier")
end

function test_rules()
   local a = attribute:new()

   assert(a, "no object created")
   assert(a:stacking_rule("dodge") == true, "dodge don't stack")
end

function test_modifier()
   local a = attribute:new()

   a:add(10, "base")
   assert(a:modifier() == 0, "invalid modifier")

   a:add(6, "enhancement")
   assert(a:modifier() == 3, "invalid modifier")

   a:add(5, "level")
   assert(a:modifier() == 5, "invalid modifier")

   a:add(3, "inherent")
   assert(a:value() == 24, "invalid value")
   assert(a:modifier() == 7, "invalid modifier")

   a:add(-2, "race")
   assert(a:value() == 22, "invalid value")
   assert(a:modifier() == 6, "invalid modifier")
end
