--- @module.randomseed

local io = require("io")
local mm = require("math")

local randomseed = {}

local randinit = 0

function randomseed:init()
   if randinit == 1 then
      return
   end

   local devrandom

   devrandom = io.open("/dev/urandom", "rb")
   if devrandom then
      local rnd = devrandom:read(4)
      if rnd then
         local seed = 0
         for i = 1, 4 do
            seed = 256 * seed + rnd:byte(i)
         end
         mm.randomseed(seed)
         randinit = 1
      end
      devrandom:close()
   end

   -- Cheesy method for platforms without /dev/random
   if randinit == 0 then
      mm.randomseed(os.time())
      randinit = 1
   end
end

return randomseed
