#!/usr/bin/env lua

local util = require("fimbul.util")
local lunit = require("lunit")
local lfs = require("lfs")
local pretty = require("pl.pretty")

module("test_util", lunit.testcase, package.seeall)

function resolve(p)
   local cur = lfs.currentdir()

   lfs.chdir(p)
   local res = lfs.currentdir()
   lfs.chdir(cur)

   return res
end

function test_util_is_relative()
   assert(util.is_relative("/test") == false,
          "A path starting with '/' is not relative.")

   assert(util.is_relative("./test") == true,
          "A path starting with '.' is relative")

   assert(util.is_relative("test") == true,
          "A path not starting with '/' is relative.")
end

function test_util_realpath()
   local c = lfs.currentdir()
   local res

   res = util.realpath("myfile.txt")
   assert(res == c .."/myfile.txt",
          "Does not properly resolve local filenames.")

   res = util.realpath("../../myfile.txt")
   assert(res == resolve(c .. "/../..") .. "/myfile.txt",
          "Does not properly resolve '..'")

   res = util.realpath("../../../../../../../../../../../../myfile.txt")
   assert(res == "/myfile.txt",
          "Does not properly resolve multiple '..'")

   res = util.realpath(".././myfile.txt")
   assert(res == resolve(c .. "/..") .. "/myfile.txt",
          "Does not properly resolve '..' and '.'")

   res = util.realpath("./myfile.txt")
   assert(res == c .. "/myfile.txt",
          "Does not propertly ignore current markers.")

   res = util.realpath("////myfile.txt")
   assert(res == "/myfile.txt",
          "Does not remove multiple '/'")
end
