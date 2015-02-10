---@module fimbul.ui.common_commands

local common_commands = {}

local base = _G

local dice_expression = require("fimbul.dice_expression")

-- Rolls dice expressions given to it
--
function common_commands._cmd_roll(arg, dispatcher, args)
   for _, i in base.pairs(args) do
      local ok, value, values = pcall(dice_expression.evaluate, i)
      dispatcher:fsay("%s: %s", i, value)
   end
end

common_commands.dice = { name = { "roll", "dice", "d" },
                         func = common_commands._cmd_roll,
                         arg = nil,
                         help = "Evaluate given dice expressions and " ..
                            "pretty print results.",
                       }

function common_commands:register(dispatcher)
   dispatcher:register(self.dice)
end

return common_commands
