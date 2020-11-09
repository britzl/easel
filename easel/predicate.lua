local M = {}


local predicates = {}



-- create a predicate
-- this will cache the predicate and return the same one if requested more than
-- once
function M.create(tags)
	for i,tag in ipairs(tags) do
		tag = type(tag) == "string" and hash(tag) or tag
	end

	for _,predicate in ipairs(predicates) do
		local found_predicate = true
		for _,tag in ipairs(tags) do
			if not predicate.tags_lut[tag] then
				found_predicate = false
				break
			end
		end
		if found_predicate then
			return predicate.handle
		end
	end

	local predicate = {
		tags_lut = {},
		handle = render.predicate(tags),
	}
	for _,tag in ipairs(tags) do
		predicate.tags_lut[tag] = true
	end

	predicates[#predicates + 1] = predicate
	return predicate.handle
end




return M