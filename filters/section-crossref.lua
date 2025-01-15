-- section-crossref.lua
-- Table to store section labels and their numbers
local sections = {}
local section_counter = 0

-- Process headers to collect section labels
function Header(elem)
	if elem.identifier and elem.identifier:match("^sec:") then
		section_counter = section_counter + 1
		sections[elem.identifier] = section_counter
	end
	return elem
end

-- Process citations that are actually cross-references
function Cite(elem)
	local id = elem.citations[1].id
	if id:match("^sec:") and sections[id] then
		-- Return a link to the section
		return {
			pandoc.Str(tostring(sections[id])),
		}
	end
	return elem
end

return {
	{ Header = Header },
	{ Cite = Cite },
}
