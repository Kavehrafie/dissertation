-- Helper functions
function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
 end
 
 function string.ends(String,End)
     return End=='' or string.sub(String,-string.len(End))==End
 end
 
 -- Debug logging
 local debug_file = io.open("filter-debug.log", "w")
 local function debug_log(msg)
     if debug_file then
         debug_file:write(os.date("%H:%M:%S") .. " " .. msg .. "\n")
         debug_file:flush()
     end
 end
 
 -- Keep track of processed files to prevent infinite recursion
 local processed_files = {}
 
 -- Recursive file finding
 function findFile(filename)
     debug_log("Looking for file: " .. filename)
     
     -- Add .md extension if not present
     if not string.ends(filename, ".md") then
         filename = filename .. ".md"
     end
     
     -- First try direct path
     local f = io.open(filename, "rb")
     if f then
         debug_log("Found file at: " .. filename)
         local content = f:read("*all")
         f:close()
         return content
     end
     
     -- Use find command to search recursively
     local cmd = string.format("find . -type f -name '%s' 2>/dev/null", filename)
     local handle = io.popen(cmd)
     local result = handle:read("*a")
     handle:close()
     
     -- If file found, read it
     if result and result ~= "" then
         local filepath = result:match("(.-)\n") or result
         debug_log("Found file through recursive search: " .. filepath)
         local f = assert(io.open(filepath, "rb"))
         local content = f:read("*all")
         f:close()
         return content
     end
     
     debug_log("File not found: " .. filename)
     return nil
 end
 
 -- Process single embed
 function processEmbed(text)
     if string.starts(text, "![[") and string.sub(text, -2) == "]]" then
         local filename = string.sub(text, 4, -3)
         debug_log("Processing embed: " .. filename)
         
         -- Check for circular references
         if processed_files[filename] then
             debug_log("Circular reference detected for: " .. filename)
             return nil
         end
         
         processed_files[filename] = true
         local content = findFile(filename)
         
         if content then
             -- Fix image paths
             content = content:gsub("!%[(.-)%]%(([^/]-%.%w+)%)", "![%1](figures/%2)")
             debug_log("Processing embedded content")
             
             -- Parse the content and process any nested embeds
             local doc = pandoc.read(content)
             if doc then
                 -- Apply the filter recursively to the parsed content
                 local walk = pandoc.walk_block
                 local blocks = doc.blocks
                 for i, block in ipairs(blocks) do
                     blocks[i] = walk(block, {Para = Para})
                 end
                 processed_files[filename] = false
                 return blocks
             end
         end
         processed_files[filename] = false
     end
     return nil
 end
 
 -- Main filter function
 function Para(elem)
     if #elem.content == 1 and elem.content[1].tag == "Str" then
         local text = elem.content[1].text
         debug_log("Processing paragraph text: " .. text)
         return processEmbed(text) or elem
     end
     return elem
 end
 
 -- Log initialization
 debug_log("Filter initialized")