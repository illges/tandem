---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/pedal'

local pedal = setmetatable({}, {__index = base})
pedal.__index = pedal

function pedal.new(args)
    args.name = "blooper"
    local self = setmetatable(base.new(args), pedal)
    self.name = "blooper"
    self.color = 18 -- blue
    self.channel = 3
    self.name_knob_map = {"volume","layers","repeats","mod a","stability","mod b"}
    self.short_names_map = {"vol","lyrs","reps","modA","stb","modB"}
    self.cc_knob_map = {14,15,16,17,18,19}
    self.mft_knob_map = {10,11,12,14,15,16}

    -- display coordinates
    self.display_x_map = {0,43,82,0,43,82}
    self.display_x_offset_map = {25,20,25,25,20,25}
    self.display_y_map = {42,42,42,52,52,52}

    self:add_params()
    self:init_lfos()
    return self
end

return pedal