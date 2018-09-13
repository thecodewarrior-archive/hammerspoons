local leftKeyCode = 55
local rightKeyCode = 54
local leftMask = 1 << 3
local rightMask = 1 << 4
local leftDown = false
local rightDown = false

local function numberToBinStr(x)
	ret=""
	while x~=1 and x~=0 do
		ret=tostring(x%2)..ret
		x=math.modf(x/2)
	end
	ret=tostring(x)..ret
	return ret
end
local function lpad(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end

local function openMenu()
end

local function closeMenu()
end

cmdTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
    local wereBothDown = leftDown and rightDown
    -- print("flags:   " .. lpad(numberToBinStr(event:rawFlags()), 25, '0'))
    if event:getKeyCode() == leftKeyCode then
        -- print("lmask:   " .. lpad(numberToBinStr(leftMask), 25, '0'))
        local masked = event:rawFlags() & leftMask
        -- print("lmasked: " .. lpad(numberToBinStr(masked), 25, '0'))
        leftDown = masked ~= 0
    end
    if event:getKeyCode() == rightKeyCode then
        -- print("rmask:   " .. lpad(numberToBinStr(rightMask), 25, '0'))
        local masked = event:rawFlags() & rightMask
        -- print("rmasked: " .. lpad(numberToBinStr(masked), 25, '0'))
        rightDown = (event:rawFlags() & rightMask) ~= 0
    end
    if leftDown and rightDown then
        openMenu()
    elseif wereBothDown then
        closeMenu()
    end

    -- if event:getKeyCode() == leftKeyCode or event:getKeyCode() == rightKeyCode then
        -- local leftStr
        -- if leftDown then 
            -- leftStr = "#"
        -- else 
            -- leftStr = "_" 
        -- end
        -- local rightStr 
        -- if rightDown then
            -- rightStr = "#"
        -- else
            -- rightStr = "_"
        -- end
        -- print(leftStr .. "< >" .. rightStr)
    -- end
    -- print(hs.inspect(event))
    -- print(numberToBinStr(event:rawFlags()))
end)
cmdTap:start()
