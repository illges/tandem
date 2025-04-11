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
    self.cc_knob_map = {14,15,16,17,18,19}
    self.mft_knob_map = {1,2,3,5,6,7}

    self:add_params()
    return self
end

return pedal