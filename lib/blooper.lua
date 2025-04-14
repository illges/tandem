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
    self.cc_knob_map = {14,15,16,17,18,19}
    self.mft_knob_map = {10,11,12,14,15,16}

    self:add_params()
    self:init_lfos()
    return self
end

return pedal