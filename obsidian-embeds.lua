function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
    return End=='' or string.sub(String,-string.len(End))==End
end

function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function Para(elem)
    if #elem.content == 1 and elem.content[1].tag == "Str" then
        local text = elem.content[1].text
        if string.starts(text, "![[") and string.sub(text, -2) == "]]" then
            local filename = string.sub(text, 4, -3)
            if not string.ends(filename, ".md") then
                filename = filename .. ".md"
            end
            local content = readAll(filename)
            -- Fix image paths by adding 'chapters/' prefix
             content = content:gsub("!%[(.-)%]%(([^/]-%.%w+)%)", "![%1](figures/%2)")
            return pandoc.read(content).blocks
        end
    end
    return elem
end
