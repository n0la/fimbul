---@module fimbul.ui.common_context

local common_context = {}

local base = _G
local string = require("string")

local pretty = require("pl.pretty")

local dice_expression = require("fimbul.dice_expression")

common_context.name = "common"

-- Rolls dice expressions given to it
--
function common_context:on_roll(d, args)
   for _, i in base.pairs(args) do
      local ok, value, values = pcall(dice_expression.evaluate, i)
      d:fsay("%s: %s", i, value)
   end
end

function common_context:_on_help(d, args)
   d:say([[
Common - methods common to every context

"roll" "dice" "d" "eval" "expr" .     ... Evaluate a dice expression and display the result.
"encounter" [name]                    ... Spawn an encounter, or monster and switch context.
"help"                                ... This bogus.
   ]])
end

function common_context:on_encounter(d, args)
   local c = args[1]

   if c == nil then
      d:error("No encounter given")
      return
   end

   local o, r = self.repository:spawn_encounter(c)

   if r == nil then
      d:fsay("Nothing found with the name '%s'", c)
   else
      d:switch_context('encounter', r)
   end
end

function common_context:on_help(d, args)
   -- Go through all modules and call "on_help()"
   for _, i in base.pairs(d:modules()) do
      if i and i["on_help"] then
         if i.name == "common" then
            i:_on_help(d, args)
         else
            -- Call "on_help"
            i:on_help(d, args)
         end
      else
         d:fsay("%s: has no help available :-(", i.name)
      end
   end
end

function common_context:new(r)
   local neu = {}

   assert(r, "The common context needs access to the repository.")

   neu.repository = r

   setmetatable(neu, self)
   self.__index = self

   return neu
end

-- Aliases for "on_roll"
common_context.on_dice = common_context.on_roll
common_context.on_d = common_context.on_roll
common_context.on_eval = common_context.on_roll
common_context.on_expr = common_context.on_roll

return common_context
