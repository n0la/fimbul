---@module fimbul.ui.cli

-- Standard CLI functions
--

local cli = {}

local repository = require('fimbul.repository')
local logger = require('fimbul.logger')

function cli.standard_parameters()
   return
[[
   -g, --game=GAME    Game engine to use
   -v, --verbose      Verbose logging output
   -h, --help             This bogus.
]]
end

function cli.standard_args(opts)
   local game

   game = opts['game'] or 'v35'
   logger.VERBOSE = opts['verbose'] or false

   return game
end

function cli.open_repository(game)
   ok, r = pcall(repository.new, repository, game)
   if not ok then
      io.stderr:write(r .. "\n")
      os.exit(3)
   end

   return r
end

function cli.dispatch_command(cmds, cmd)
   if cmd == nil then
      io.stderr:write("No command given.\n")
      os.exit(2)
   end

   local c = cmds[cmd]

   if c == nil then
      io.stderr:write("No such command: " .. cmd .. ". Try help.\n")
      os.exit(2)
   end

   ok, ret = pcall(c.handler)
   if ok then
      os.exit(ret or 0)
   else
      io.stderr:write(ret .. "\n")
      os.exit(3)
   end
end

return cli
