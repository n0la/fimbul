#!/usr/bin/env lua

-- Unit test for stacked value
module("test_v35_creature", lunit.testcase, package.seeall)

local creature = require("fimbul.v35.creature")
local lunit = require("lunit")
local pretty = require("pl.pretty")

function test_construction()
   local c = creature:new()

   -- TODO
end
