---@module fimbul.ui.cli

-- Standard CLI functions
--

local cli = {}

local repository = require('fimbul.repository')
local logger = require('fimbul.logger')

function cli.args()
   local cliargs = require('cliargs')

   cliargs:option('-g, --game=GAME', 'Game engine to use', 'v35')
   cliargs:flag('-v, --verbose', 'Verbose logging output')

   return cliargs
end

function cli.parse(cliargs)
   local args, err = cliargs:parse(_G.arg)

   if not args and err then
      io.stderr:write(
         string.format("%s: %s; re-run with help for usage\n", cli.name, err))
      os.exit(1)
   end

   local game

   game = args['game'] or 'v35'
   logger.VERBOSE = args['verbose'] or false

   return args, game
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
