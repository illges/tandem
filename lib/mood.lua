---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/pedal'

local pedal = setmetatable({}, {__index = base})
pedal.__index = pedal

function pedal.new(args)
    args.name = "mood"
    local self = setmetatable(base.new(args), pedal)
    self.name = "mood"
    self.color = 75 -- orange
    self.channel = 2
    self.name_knob_map = {"time","mix","length","mod a","clock","mod b"}
    self.short_names_map = {"time","mix","len","modA","clck","modB"}
    self.cc_knob_map = {14,15,16,17,18,19}
    self.mft_knob_map = {1,2,3,5,6,7}

    -- display coordinates
    self.display_x_map = {0,43,82,0,43,82}
    self.display_x_offset_map = {25,20,25,25,20,25}
    self.display_y_map = {15,15,15,25,25,25}

    self:add_params()
    self:init_lfos()
    return self
end

return pedal