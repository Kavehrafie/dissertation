-- obsidian-embeds-exp.lua
-- Helper functions for string manipulation
function string.starts(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start
end

function string.ends(String, End)
	return End == "" or string.sub(String, -string.len(End)) == End
end

-- Keep track of processed files
local processed_files = {}
local current_depth = 0
local MAX_DEPTH = 10

-- Debug logging setup
local debug_file = io.open("filter-debug.log", "w")
function debug_log(msg)
	if debug_file then
		debug_file:write(string.format("[%s] %s%s\n", os.date("%H:%M:%S"), string.rep("  ", current_depth), msg))
		debug_file:flush()
	end
end

-- Function to remove Obsidian callouts
function removeCallouts(content)
	-- First, ensure we have consistent line endings
	content = content:gsub("\r\n", "\n")

	-- Process the content line by line
	local lines = {}
	local in_callout = false

	for line in content:gmatch("([^\n]*)\n?") do
		-- Check if this line starts a callout
		if line:match("^> %[!") then
			in_callout = true
			-- Skip this line
			-- Check if we're in a callout and this is a continuation
		elseif in_callout and line:match("^>") then
			-- Skip this line
			-- Check if we're in a callout and hit an empty line or non-callout line
		elseif in_callout and (line == "" or not line:match("^>")) then
			in_callout = false
			table.insert(lines, line)
		else
			-- Not in a callout, keep the line
			table.insert(lines, line)
		end
	end

	-- Join the lines back together
	local result = table.concat(lines, "\n")

	-- Clean up any multiple newlines that might have been created
	result = result:gsub("\n\n+", "\n\n")

	return result
end

-- Function to generate a unique suffix for a file
function getFileSuffix(filepath)
	-- Extract a meaningful identifier from the filepath
	local identifier = filepath:match("([^/]+)%.md$") or filepath
	-- Remove any spaces or special characters
	identifier = identifier:gsub("[^%w]", "_")
	return identifier
end

-- Function to process footnotes in content
function processFootnotes(content, filepath)
	local suffix = getFileSuffix(filepath)
	debug_log("Processing footnotes with suffix: " .. suffix)

	-- First update the references
	content = content:gsub("%[%^(%d+)%]([^:])", function(num, next_char)
		return "[^" .. num .. "_" .. suffix .. "]" .. next_char
	end)

	-- Then update the definitions
	content = content:gsub("%[%^(%d+)%]:", function(num)
		return "[^" .. num .. "_" .. suffix .. "]:"
	end)

	return content
end

-- Function to find and read a file
function findFile(filename)
	debug_log("Looking for file: " .. filename)

	-- Add .md extension if not present
	if not string.ends(filename, ".md") then
		filename = filename .. ".md"
	end

	-- Try common locations
	local paths = {
		"./",
		"./chapters/",
		"../chapters/",
	}

	for _, path in ipairs(paths) do
		local filepath = path .. filename
		local f = io.open(filepath, "rb")
		if f then
			debug_log("Found file at: " .. filepath)
			local content = f:read("*all")
			f:close()
			return content, filepath
		end
	end

	-- Fallback to recursive search
	local cmd = string.format("find . -type f -name '%s' 2>/dev/null", filename)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()

	if result and result ~= "" then
		local filepath = result:match("(.-)\n") or result
		debug_log("Found file through search: " .. filepath)
		local f = assert(io.open(filepath, "rb"))
		local content = f:read("*all")
		f:close()
		return content, filepath
	end

	debug_log("File not found: " .. filename)
	return nil
end

-- Find all embeds in a text
function findEmbeds(text)
	local embeds = {}
	for embed in text:gmatch("!%[%[(.-)%]%]") do
		table.insert(embeds, embed)
	end
	return embeds
end

-- Process a single file's content
function processFileContent(content, filepath)
	debug_log("Processing content from: " .. filepath)

	-- Add debug logging for headers with labels
	content:gsub("#+ .-{#sec:.-}", function(match)
		debug_log("Found header with label: " .. match)
		return match
	end)
	-- Remove callouts first
	content = removeCallouts(content)

	-- Fix image paths
	content = content:gsub("!%[(.-)%]%(([^/]-%.%w+)%)", function(alt, img)
		return string.format("![%s](optimized_images/%s)", alt, img)
	end)

	-- Process footnotes before handling embeds
	content = processFootnotes(content, filepath)

	-- Find and process all embeds
	local embeds = findEmbeds(content)
	for _, embed in ipairs(embeds) do
		debug_log("Found nested embed: " .. embed)
		local escaped_pattern = embed:gsub("([%%{}])", "%%%1")
		local escaped_replacement = processEmbed("![[" .. embed .. "]]")
		if escaped_replacement then
			escaped_replacement = escaped_replacement:gsub("%%", "%%%%")
			content = content:gsub("!%[%[" .. escaped_pattern .. "%]%]", escaped_replacement)
		end
	end

	return content
end

-- Function to process embedded content
function processEmbed(text)
	if string.starts(text, "![[") and string.sub(text, -2) == "]]" then
		local filename = string.sub(text, 4, -3)
		debug_log("Processing embed: " .. filename)

		if current_depth >= MAX_DEPTH then
			debug_log("Max recursion depth reached")
			return nil
		end

		if processed_files[filename] then
			debug_log("Circular reference detected: " .. filename)
			return nil
		end

		processed_files[filename] = true
		current_depth = current_depth + 1

		local content, filepath = findFile(filename)
		if content then
			content = processFileContent(content, filepath)
			current_depth = current_depth - 1
			processed_files[filename] = false
			return content
		end

		current_depth = current_depth - 1
		processed_files[filename] = false
	end
	return nil
end

-- Main filter function for paragraphs
function Para(elem)
	if #elem.content == 1 and elem.content[1].tag == "Str" then
		local text = elem.content[1].text
		debug_log("Processing paragraph: " .. text)
		local processed = processEmbed(text)
		if processed then
			return pandoc.read(processed).blocks
		end
	end
	return elem
end

-- Initialize filter
debug_log("Filter initialized")

-- Cleanup when done
function PandocEnd()
	if debug_file then
		debug_file:close()
	end
end