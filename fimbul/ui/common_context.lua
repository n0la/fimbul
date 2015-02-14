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

"roll" "dice" "d" .                   ... Roll a dice expression and display the result.
"spawn" [encounter|monster] n         ... Spawn an encounter, or monster and switch context.
"help"                                ... This bogus.
   ]])
end

function common_context:on_spawn(d, args)
   local w = args[1]
   local c = args[2]

   if w ~= "monster" and w ~= "encounter" then
      d:error("Please specify either 'encounter' or 'monster'")
      return
   end

   if c == nil then
      d:error("Nothing given to spawn.")
      return
   end

   local r = self.repository:find(string.lower(w), c)

   if #r == 0 then
      d:fsay("Nothing found with the name '%s'", c)
   elseif #r > 1 then
      d:fsay("The search term '%s' does not yield an unique result.", c)
   else
      if w == "encounter" then
         -- Switch to encounter context
         d:switch_context(w, r[1])
      end
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

return common_context
