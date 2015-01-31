--- @module fimbul.data_repository

local r = {}

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
         local s = posix.stat(full)

         if s.type == "directory" then
            if directory ~= "" and directory == iter then
               self:_find_all("",  glob, full, results)
            else
               self:_find_all(directory, glob, full, results)
            end
         elseif s.type == "regular" then
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

function r.new()
   local neu = {}

   data_repository.__index = data_repository
   setmetatable(neu, data_repository)

   return neu
end

function r.open(blob)
   local n = r.new()
   n:open(blob)
   return n
end

return r
