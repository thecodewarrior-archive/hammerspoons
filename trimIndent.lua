-- credit: https://gist.github.com/jaredallard/ddb152179831dd23b230
-- modified to include the matched delimiters at the end of each element
-- split a string
function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
        table.insert( result, string.sub( self, from , delim_to ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end

local obj={}
obj.__index = obj
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
obj.choiceIcon = hs.image.imageFromPath(script_path() .. "/trim-indent.png")

function obj:init()
    obj.menu = function()
        return {
            title="Trim indent",
            fn=function()
                self:trim()
            end,
            disabled = not hs.pasteboard.readString()
        }
    end

    self.choice = function()
        print("Creating indent trim choices")
        local text = hs.pasteboard.readString()
        if text then
            print("Text in clipboard, returning choice")
            local depth = self:calculateDepth(text)
            return {
                {
                    text = "Trim indents",
                    subText = "Depth: " .. depth,
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
function obj:trim()
    local text = hs.pasteboard.readString()

    if text then
        local depth = self:calculateDepth(text)
        local trimmed = ""
        for _, line in ipairs(text:split("[\r\n]")) do
            trimmed = trimmed .. string.sub(line, depth+1)
        end
        hs.pasteboard.setContents(trimmed)
    end
end

function obj:calculateDepth(text)
    local depth = 1000000
    local lines = text:split("[\r\n]")
    print("Found " .. #lines .. " lines")
    for n, line in ipairs(lines) do
        local _, _, indent = string.find(line, "^(%s*)")
        if indent:len() < line:len() then 
            if indent:len() < depth then
                depth = indent:len()
                print("Line " .. n .. " had an indent of length " .. indent:len() .. ". Indent depth has been set to " .. depth)
            else
                print("Line " .. n .. " had an indent of length " .. indent:len() .. ". Current indent depth is unchanged")
            end
        else
            print("Line " .. n .. " was empty or entirely whitespace. Skipping.")
        end
    end
    return depth
end

obj:init()
return obj
