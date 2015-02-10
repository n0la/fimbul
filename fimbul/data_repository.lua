--- @module fimbul.data_repository

local base = _G
local table = require("table")

local lfs = require("lfs")
local posix = require("posix")

local data_repository = {}

function data_repository:open(blob)
   if not blob.name and not blob.path then
      base.error("A data repository should either have a name or a path")
   end

   self.path = blob.path
   self.name = blob.name
   self.url = blob.url
end

function data_repository:_find_all(directory, glob, path, results)
   for iter, dir in lfs.dir(path) do
      if iter ~= "." and iter ~= ".." then
         local full = posix.realpath(path .. "/" .. iter)

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
   local g = glob or "^.*%.yml$"
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
