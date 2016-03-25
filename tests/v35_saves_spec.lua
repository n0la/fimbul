#!/usr/bin/env lua

describe('fimbul.v35.saves',
function()

   local saves = require("fimbul.v35.saves")

   describe('construction',
   function()
      local s = saves:new()

      assert.are_not.equal(s, nil)
      assert.are_not.equal(s.will, nil)
      assert.are_not.equal(s.reflex, nil)
      assert.are_not.equal(s.fortitude, nil)

      assert.is.equal(s.will:value(), 0)
      assert.is.equal(s.reflex:value(), 0)
      assert.is.equal(s.fortitude:value(), 0)
   end)
end)
