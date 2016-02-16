---@module fimbul.ui.cli

-- Standard CLI functions
--

local cli = {}

local repository = require('fimbul.repository')

function cli.standard_args(opts)
   local repo

   if opts['repository'] ~= nil then
      repo = opts['repository']
   else
      repo = '.'
   end

   return repo
end

function cli.open_repository(repo)
   ok, r = pcall(repository.new, repository, repo)
   if not ok then
      io.stderr:write(r .. "\n")
      os.exit(3)
   end

   return r
end

function cli.dispatch_command(cmds, cmd)
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
