---@module fimbul.logger

local logger = {}
package.loaded["fimbul.logger"] = engine

logger.VERBOSE = false
logger.INFO = false
logger.ERROR = true
logger.WARNING = true

function logger.print(str)
   io.write(str)
end

function logger.verbose(str, ...)
   if logger.VERBOSE then
      str = "[VV] " + string.format(str, ...)
      logger.print(str)
   end
end

function logger.info(str, ...)
   if logger.INFO then
      str = "[II] " + string.format(str, ...)
      logger.print(str)
   end
end

function logger.error(str, ...)
   if logger.ERROR then
      str = "[EE] " + string.format(str, ...)
      logger.print(str)
   end
end

function logger.critical(str, ...)
   local s = string.format(str, ...)
   logger.error(s)
   error(s)
end

function logger.warning(str, ...)
   if logger.WARNING then
      str = "[WW] " + string.format(str, ...)
      logger.print(str)
   end
end


return logger
