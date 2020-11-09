# Easel
Easel is used to switch render script content at run-time.

# Installation
You can use Easel in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

https://github.com/britzl/easel/archive/master.zip

Or point to the ZIP file of a [specific release](https://github.com/britzl/easel/releases).

# Usage
Easel uses a concept of programs to represent the contents of an active render script. Easel programs are run from the render context and has access to all functions from the render.* namespace.

## Creating programs
An Easel program is represented as a Lua table with life cycle functions:

```Lua
local program = {}

function program.init(self)
	-- called when the program is used
end

function program.final(self)
	-- called when the program is no longer used
end

function program.update(self, dt)
	-- called every frame while the program is used
	-- dt is calculated using socket.gettime()
end

function program.on_messages(self, message_id, message, sender)
	-- called when a message is sent to the render script and the program is in use
end
```

## Using programs
A program is added, used and removed using Easel:

```Lua
local easel = require "easel.easel"

-- add the program and assign it is "myprogram"
easel.add_program("myprogram", program)

-- use the program with id "myprogram"
-- this will call the init() function of the program
-- if another program was active the final() function of that program will be called
easel.use_program("myprogram")

-- remove the program with id "myprogram"
easel.remove_program("myprogram")
```
