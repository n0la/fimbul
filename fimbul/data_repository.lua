--- @module fimbul.data_repository

local base = _G
local table = require("table")

local lfs = require("lfs")
local util = require("fimbul.util")

local data_repository = {}

function data_repository:open(blob)
   if not blob.name and not blob.path then
      base.error("A data repository should either have a name or a path")
   end

   self.path = blob.path
   self.name = blob.name

   self.codepath = self.path .. "/lib/"
   self.blocks = {}

   files = {}

   if not util.isdir(self.codepath) then
      return
   end

   -- load all code blocks if there are some
   self:_find_all('', '^.*%.lua$', self.codepath, files)

   for _, f in base.ipairs(files) do
      local ok, fun = pcall(loadfile, f)

      if not ok then
         error(fun)
      end

      local block = fun()

      if block == nil or type(block) ~= 'table' then
         error('Code chunk "' .. f .. '" did not return a table.')
      end

      table.insert(self.blocks, block)
   end
end

function data_repository:has_function(name)
   for _, block in base.ipairs(self.blocks) do
      if block[name] ~= nil and type(block[name]) == 'function' then
         return true, block[name]
      end
   end

   return false, nil
end

function data_repository:call_function(name, ...)
   local ok, fun = self:has_function(name)

   if ok then
      return fun(...)
   else
      return nil
   end
end

function data_repository:_find_all(directory, glob, path, results)
   for iter, dir in lfs.dir(path) do
      if iter ~= "." and iter ~= ".." then
         local full = util.realpath(path .. "/" .. iter)

         if util.isdir(full) then
            if directory ~= "" and directory == iter then
               self:_find_all("",  glob, full, results)
            else
               self:_find_all(directory, glob, full, results)
            end
         elseif util.isfile(full) then
            if string.match(iter, glob) and directory == "" then
               table.insert(results, tostring(full))
            end
         end
      end
   end
end

function data_repository:find_all(directory, glob)
   local g = glob or "^.*%.y[a]*ml$"
   local d = directory or ''
   local results = {}

   self:_find_all(d, g, self.path, results)

   return results
end

function data_repository:new(blob)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   if blob then
      neu:open(blob)
   end

   return neu
end

return data_repository
