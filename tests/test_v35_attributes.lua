#!/usr/bin/env lua

-- Unit test for stacked value
module("test_v35_attributes", lunit.testcase, package.seeall)

local attributes = require("fimbul.v35.attributes")
local lunit = require("lunit")
local pretty = require("pl.pretty")

local function test_attribute(a, name)
   assert(a, "no " .. name .. " attribute")
   assert(a:value() == 0, "attribute " .. name .. " is not zero")
   assert(a:modifier() == -5, "attribute " .. name .. " modifier is wrong")
end

function test_construction()
   local a = attributes:new()

   assert(a, "no object created")

   test_attribute(a.strength, "strength")
   test_attribute(a.dexterity, "dexterity")
   test_attribute(a.constitution, "constitution")
   test_attribute(a.intelligence, "intelligence")
   test_attribute(a.wisdom, "wisdom")
   test_attribute(a.charisma, "charisma")
end
