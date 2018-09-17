local obj={}
obj.__index = obj

obj.callbacks = {}
obj.choices = {}
obj.chooser = hs.chooser.new(function(item)
    print("Chose item " .. hs.inspect(item))
    if item then
        obj.callbacks[item.index]()
    end
end)

function obj:add(callback)
    print("Added choice " .. hs.inspect(item))
    table.insert(self.choices, callback)
end

function obj:openMenu()
    self.chooser:refreshChoicesCallback()
    self.chooser:show()
end

function obj:start()
    self.chooser:choices(function()
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

    self.cmdTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function (event)
        if hyper.shift and event:getKeyCode() == hs.keycodes.map.space then
            print("opening popup menu")
            self:openMenu()
        end
    end)
    self.cmdTap:start()
end

return obj
