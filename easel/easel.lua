local M = {}

-- messages
local USE_PROGRAM = hash("lumiere_use_program")
local REMOVE_PROGRAM = hash("lumiere_remove_program")


local programs = {}

local current_program = default_program

local time = 0


local function log(...)
	print(...)
end




-- initialize lumiere
function M.init(self)
	log("init")
	time = socket.gettime()
end

-- update lumiere
function M.update(self)
	local now = socket.gettime()
	local dt = now - time
	time = now

	-- update current program
	if current_program.update then
		current_program.update(current_program.context, dt)
	end
end

-- handle messages
-- mainly switching of programs and handling default render messages
function M.on_message(self, message_id, message, sender)
	if message_id == USE_PROGRAM then
		local id = message.id
		assert(id, "You must provide a program id")
		assert(programs[id], "You must provide a valid program id")
		log("USE_PROGRAM", id)
		if current_program == programs[id] then
			print("Program already in use")
			return
		end
		if current_program and current_program.final then
			log("calling final on current_program", current_program.id)
			current_program.final(current_program.context)
		end
		current_program = programs[id]
		current_program.id = id
		if current_program.init then
			log("calling init on current_program", current_program.id)
			current_program.init(current_program.context)
		end
	elseif message_id == REMOVE_PROGRAM then
		local id = message.id
		assert(id, "You must provide a program id")
		assert(programs[id], "You must provide a valid program id")
		if current_program == programs[id] then
			current_program.final(current_program.context)
			current_program = programs["default"]
		end
		programs[id] = nil
	else
		if current_program.on_message then
			current_program.on_message(current_program.context, message_id, message, sender)
		end
	end
end

function M.on_reload(self)
	if current_program.on_reload then
		current_program.on_reload(current_program.context)
	end
end

function M.add_program(id, program)
	assert(id, "You must provide a program id")
	assert(program and type(program) == "table", "You must provide a program")
	programs[id] = {
		id = id,
		context = {},
		init = program.init,
		update = program.update,
		final = program.final,
		on_message = program.on_message,
		on_reload = program.on_reload,
	}
end

function M.use_program(id)
	assert(id, "You must provide a program id")
	assert(programs[id], "You must provide a valid program id")
	msg.post("@render:", USE_PROGRAM, { id = id })
end

function M.remove_program(id)
	assert(id, "You must provide a program id")
	assert(programs[id], "You must provide a valid program id")
	msg.post("@render:", REMOVE_PROGRAM, { id = id })
end




return M