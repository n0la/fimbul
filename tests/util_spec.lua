#!/usr/bin/env lua

describe('util',
function()
   local util = require('fimbul.util')
   local lfs = require('lfs')

   function resolve(p)
      local cur = lfs.currentdir()

      lfs.chdir(p)
      local res = lfs.currentdir()
      lfs.chdir(cur)

      return res
   end

   describe('is_relative',
   function()
      assert.is.equal(util.is_relative("/test"), false)
      assert.is.equal(util.is_relative("./test"), true)
      assert.is.equal(util.is_relative("test"), true)
   end)

   describe('realpath',
   function()
      local c = lfs.currentdir()
      local res

      assert.is.equal(util.realpath("/.."), "/")
      assert.is.equal(util.realpath("/../../../.."), "/")
      assert.is.equal(util.realpath("."), c)
      assert.is.equal(util.realpath(c), c)
      assert.is.equal(util.realpath("myfile.txt"), c .."/myfile.txt")

      assert.is.equal(util.realpath("../../myfile.txt"),
                      resolve(c .. "/../..") .. "/myfile.txt")

      res = util.realpath("../../../../../../../../../../../../myfile.txt")
      assert.is.equal(res, "/myfile.txt")

      res = util.realpath(".././myfile.txt")
      assert.is.equal(res, resolve(c .. "/..") .. "/myfile.txt")

      res = util.realpath("./myfile.txt")
      assert.is.equal(res, c .. "/myfile.txt")

      res = util.realpath("////myfile.txt")
      assert.is.equal(res, "/myfile.txt")
   end)
end)
