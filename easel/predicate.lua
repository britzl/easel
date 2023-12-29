local M = {}

local predicates = {}
local function find_pred(hashed_list)
	for _,predicate in ipairs(predicates) do
		local found_predicate = false
		if #predicate == #hashed_list then
			found_predicate = true
			for __,tag in ipairs(hashed_list) do
				if not predicate.tags_lut[tag] then
					found_predicate = false
					break
				end
			end
		end
		if found_predicate then return predicate end
	end
end

local function add_pred(hashed_tags)
	local new_predicate = {
		tags_lut = {},
		handle = render.predicate(hashed_tags),
	}
	for _,tag in ipairs(hashed_tags) do
		new_predicate.tags_lut[tag] = true
	end
	predicates[#predicates + 1] = new_predicate
end

function M.create(tags)
	local hashed_tags = {}
	for k,v in ipairs(tags) do
		hashed_tags[k] = hash(tags[k])
	end	
	local existing_pred = find_pred(hashed_tags)
	if existing_pred then
		return existing_pred.handle
	else
		add_pred(hashed_tags)
		return predicates[#predicates].handle
	end
end 

return M
