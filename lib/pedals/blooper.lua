---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/pedal'
local _tt = include 'lib/threshold_trigger'

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

    -- extra knob 1
    self.extra_knob_num = 9
    self.extra_knob_1_name = "arm"
    self.extra_knob_cc = 3
    self.extra_knob_value = 127
    self.extra_knob_1_color = 45
    self.extra_knob_1_color_options = {45, 85}

    -- display coordinates
    self.display_x_map = {0,43,82,0,43,82}
    self.display_x_offset_map = {25,20,25,25,20,25}
    self.display_y_map = {42,42,42,52,52,52}

    self.tt = _tt.new({debug=true, cc=self.extra_knob_cc, value=127, channel=self.channel})
    self:add_params()
    self:init_lfos()
    return self
end

function pedal:extra_knob_1_press()
    self.tt:toggle_threshold_trigger()
    self.extra_knob_1_color = self.tt.armed == 1 and self.extra_knob_1_color_options[2] or self.extra_knob_1_color_options[1]
end

return pedal