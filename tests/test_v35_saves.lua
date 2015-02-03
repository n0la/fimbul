#!/usr/bin/env lua

-- Unit test for stacked value
module("test_v35_saves", lunit.testcase, package.seeall)

local saves = require("fimbul.v35.saves")
local lunit = require("lunit")
local pretty = require("pl.pretty")

function test_construction()
   local s = saves:new()

   assert(s, "no object created")
   assert(s.will, "no will save created")
   assert(s.reflex, "no reflex save created")
   assert(s.fortitude, "no fortitude save created")
end

function test_zero()
   local s = saves:new()

   assert(s.will:value() == 0, "will save is not zero after creation")
   assert(s.reflex:value() == 0, "reflex save is not zero after creation")
   assert(s.fortitude:value() == 0, "fortitude save is not zero after creation")
end
