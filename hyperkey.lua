local obj={}
obj.__index = obj

local lCtrl  = 1 << 0
local lShift = 1 << 1
local rShift = 1 << 2
local lCmd   = 1 << 3
local rCmd   = 1 << 4
local lOpt   = 1 << 5
local rOpt   = 1 << 6
local rCtrl  = 1 << 13
local fn     = 1 << 23

obj.ctrl  = false
obj.shift = false
obj.cmd   = false
obj.opt   = false

function obj:start()
    self.cmdTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function (event)
        flags = event:rawFlags()
        self.ctrl = flags & lCtrl ~= 0 and flags & rCtrl ~= 0
        self.shift = flags & lShift ~= 0 and flags & rShift ~= 0
        self.cmd = flags & lCmd ~= 0 and flags & rCmd ~= 0
        self.opt = flags & lOpt ~= 0 and flags & rOpt ~= 0
    end)
    self.cmdTap:start()
end

-- local function numberToBinStr(x)
-- 	ret=""
-- 	while x~=1 and x~=0 do
-- 		ret=tostring(x%2)..ret
-- 		x=math.modf(x/2)
-- 	end
-- 	ret=tostring(x)..ret
-- 	return ret
-- end
-- 
-- local function lpad(str, len, char)
--     if char == nil then char = ' ' end
--     return string.rep(char, len - #str) .. str
-- end

return obj
