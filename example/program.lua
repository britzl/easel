local predicate = require "easel.predicate"


local M = {}



math.randomseed(socket.gettime())
local nv = {}
for i=1,10 do
	nv[i] = math.random()
end
local function noise(x)
	local xi = math.floor(x)
	local min = 1 + (xi % #nv)
	local t = x - xi
	local max = (min - #nv) == 0 and 1 or min + 1
	return vmath.lerp(t, nv[min], nv[max])
end



--
-- projection that centers content with maintained aspect ratio and optional zoom
--
local function fixed_projection(near, far, zoom)
	local projected_width = render.get_window_width() / (zoom or 1)
	local projected_height = render.get_window_height() / (zoom or 1)
	local xoffset = -(projected_width - render.get_width()) / 2
	local yoffset = -(projected_height - render.get_height()) / 2
	return vmath.matrix4_orthographic(xoffset, xoffset + projected_width, yoffset, yoffset + projected_height, near, far)
end

function M.init(self)
	self.tile_pred = predicate.create({"tile"})
	self.gui_pred = predicate.create({"gui"})
	self.text_pred = predicate.create({"text"})
	self.particle_pred = predicate.create({"particle"})
	
	self.clear_color = vmath.vector4(0, 0, 0, 0)

	self.view = vmath.matrix4()
	self.rt = 0.4
	self.gt = 0.2
	self.bt = 0.8
end

function M.final(self)
end

function M.update(self, dt)
	self.rt = self.rt + dt
	self.gt = self.gt + dt
	self.bt = self.bt + dt
	self.clear_color.x = noise(self.rt)
	self.clear_color.y = noise(self.gt)
	self.clear_color.z = noise(self.bt)

	render.set_depth_mask(true)
	render.set_stencil_mask(0xff)
	render.clear({[render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0})

	render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())
	render.set_view(self.view)

	render.set_depth_mask(false)
	render.disable_state(render.STATE_DEPTH_TEST)
	render.disable_state(render.STATE_STENCIL_TEST)
	render.enable_state(render.STATE_BLEND)
	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)
	render.disable_state(render.STATE_CULL_FACE)

	render.set_projection(fixed_projection(-1, 1, 2))

	render.draw(self.tile_pred)
	render.draw(self.particle_pred)
	render.draw_debug3d()

	-- render GUI
	--
	render.set_view(vmath.matrix4())
	render.set_projection(vmath.matrix4_orthographic(0, render.get_window_width(), 0, render.get_window_height(), -1, 1))

	render.enable_state(render.STATE_STENCIL_TEST)
	render.draw(self.gui_pred)
	render.draw(self.text_pred)
	render.disable_state(render.STATE_STENCIL_TEST)
end




return M