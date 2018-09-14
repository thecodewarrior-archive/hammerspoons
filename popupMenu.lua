local obj={}
obj.__index = obj

local leftKeyCode = 55
local rightKeyCode = 54
local leftMask = 1 << 3
local rightMask = 1 << 4

obj.leftDown = false
obj.rightDown = false
obj.wereBothDown = false

obj.callbacks = {}
obj.choices = {}
obj.chooser = hs.chooser.new(function(item)
    print("Chose item " .. hs.inspect(item))
    if item then
        obj.callbacks[item.index]()
    end
end)

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

function obj:add(callback)
    print("Added choice " .. hs.inspect(item))
    table.insert(obj.choices, callback)
end

function obj:openMenu()
    obj.chooser:refreshChoicesCallback()
    obj.chooser:show()
end

function obj:start()
    obj.chooser:choices(function()
        print("Refreshing choices")
        local choices = {}
        self.callbacks = {}
        for _, callback in ipairs(self.choices) do
            local items = callback()
            print("Got " .. #items .. " choices: " .. hs.inspect(items))
            for _, choice in ipairs(items) do
                local callback = choice.fire
                choice.fire = nil
                table.insert(self.callbacks, callback)

                choice.index = #self.callbacks
                print("Adding choice" .. hs.inspect(choice))
                table.insert(choices, choice)
            end
        end
        return choices
    end)

    obj.cmdTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function (event)
        -- print("flags:   " .. lpad(numberToBinStr(event:rawFlags()), 25, '0'))
        if event:getKeyCode() == leftKeyCode then
            -- print("lmask:   " .. lpad(numberToBinStr(leftMask), 25, '0'))
            local masked = event:rawFlags() & leftMask
            -- print("lmasked: " .. lpad(numberToBinStr(masked), 25, '0'))
            self.leftDown = masked ~= 0
        end
        if event:getKeyCode() == rightKeyCode then
            -- print("rmask:   " .. lpad(numberToBinStr(rightMask), 25, '0'))
            local masked = event:rawFlags() & rightMask
            -- print("rmasked: " .. lpad(numberToBinStr(masked), 25, '0'))
            self.rightDown = (event:rawFlags() & rightMask) ~= 0
        end

        local areBothDown = self.leftDown and self.rightDown
        if areBothDown and not self.wereBothDown then
            print("opening popup menu")
            self:openMenu()
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
        --
        self.wereBothDown = areBothDown
    end)
    obj.cmdTap:start()
end

return obj
