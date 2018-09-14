local obj = {}
obj.__index = obj

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
obj.choiceIcon = hs.image.imageFromPath(script_path() .. "/hastebin-icon.png")

function obj:init()
    self.menu = function()
        return {
            title="Upload to Hastebin",
            fn=function() 
                self:upload()
            end,
            disabled = not hs.pasteboard.readString()
        }
    end

    self.choice = function()
        print("Creating hastebin choices")
        local text = hs.pasteboard.readString()
        if text then
            print("Text in clipboard, returning choice")
            return {
                {
                    text = "Upload copied text to hastebin",
                    subText = text:gsub("[\r\n]", " ⏎ "),
                    image = nil,
                    fire = function()
                        self:upload()
                    end
                }
            }
        end
        print("No text in clipboard, returning empty table")
        return {}
    end
end


function obj:upload()
    local text = hs.pasteboard.readString()

    if text then
        local url = "https://hastebin.com/documents"
        local headers = {}
        local payload = text

        hs.http.asyncPost(url, payload, headers, function(status, body, headers)
            print(status, headers, body)
            if status == 200 then
                local response = hs.json.decode(body)
                local imageURL = "https://hastebin.com/" .. response.key
                hs.urlevent.openURLWithBundle(imageURL, hs.urlevent.getDefaultHandler("http"))
            end
        end)
    end
end

obj:init()

return obj
