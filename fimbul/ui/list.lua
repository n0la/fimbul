---@module fimbul.ui.list_manipulation

-- Common methods that help context to manipulate their lists

local list = {}

local base = _G

local util = require("fimbul.util")
local pretty = require("pl.pretty")

function list:remove(strs, ...)
   local c = 0

   if #strs == 0 then
      d:error("remove: no parameter(s) given.")
      return 0
   end

   for _, l in base.pairs({...}) do
      for _, s in base.pairs(strs) do
         c = c + util.removeif(l,
                               function(i)
                                  return util.name_matches(i, s)
                              end)
      end
   end

   self.dispatcher:fsay("%d item(s) removed.", c)
end

function list:new(d)
   local neu = {}

   neu.dispatcher = d

   setmetatable(neu, self)
   self.__index = self

   return neu
end

return list
