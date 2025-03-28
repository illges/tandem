---@diagnostic disable: undefined-global, lowercase-global

local base = {}
base.__index = base

function base.new(args)
    local self = setmetatable({}, base)

    -- pedal knobs
    self.knob_1 = 64
    self.knob_2 = 64
    self.knob_3 = 64
    self.knob_4 = 64
    self.knob_5 = 64
    self.knob_6 = 64

    self.dm = args.dm
    return self
end

function base:add_params()
    params:add_group(self.name, 7)
    --params:add_separator(self.name)
    params:add{
        type = "number", id = (self.name.."_channel"),
        name = ("channel"),
        min = 1, max = 16,
        default = self.channel,
        action = function(x) self.channel = x end
    }
    params:add{
        type = "number", id = (self.name.."_knob_1"),
        name = (self.name_knob_map[1]),
        min = 0, max = 127,
        default = self.knob_1,
        action = function(x)
            self.knob_1 = x
            self.dm:device_out():cc(self.cc_knob_map[1], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_knob_2"),
        name = (self.name_knob_map[2]),
        min = 0, max = 127,
        default = self.knob_2,
        action = function(x)
            self.knob_2 = x
            self.dm:device_out():cc(self.cc_knob_map[2], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_knob_3"),
        name = (self.name_knob_map[3]),
        min = 0, max = 127,
        default = self.knob_3,
        action = function(x)
            self.knob_3 = x
            self.dm:device_out():cc(self.cc_knob_map[3], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_knob_4"),
        name = (self.name_knob_map[4]),
        min = 0, max = 127,
        default = self.knob_4,
        action = function(x)
            self.knob_4 = x
            self.dm:device_out():cc(self.cc_knob_map[4], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_knob_5"),
        name = (self.name_knob_map[5]),
        min = 0, max = 127,
        default = self.knob_5,
        action = function(x)
            self.knob_5 = x
            self.dm:device_out():cc(self.cc_knob_map[5], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_knob_6"),
        name = (self.name_knob_map[6]),
        min = 0, max = 127,
        default = self.knob_6,
        action = function(x)
            self.knob_6 = x
            self.dm:device_out():cc(self.cc_knob_map[6], x, self.channel)
        end
    }
end

function base:delta(n,d)
    if n==self.mft_knob_map[1] then return self:delta_knob_1(d)
    elseif n==self.mft_knob_map[2] then return self:delta_knob_2(d)
    elseif n==self.mft_knob_map[3] then return self:delta_knob_3(d)
    elseif n==self.mft_knob_map[4] then return self:delta_knob_4(d)
    elseif n==self.mft_knob_map[5] then return self:delta_knob_5(d)
    elseif n==self.mft_knob_map[6] then return self:delta_knob_6(d)
    end
end

function base:delta_knob_1(d)
    set_message(self.name.." "..self.name_knob_map[1].." turning "..d)
    params:delta(self.name.."_knob_1", d)
    return self.knob_1
end

function base:delta_knob_2(d)
    set_message(self.name.." "..self.name_knob_map[2].." turning "..d)
    params:delta(self.name.."_knob_2", d)
    return self.knob_2
end

function base:delta_knob_3(d)
    set_message(self.name.." "..self.name_knob_map[3].." turning "..d)
    params:delta(self.name.."_knob_3", d)
    return self.knob_3
end

function base:delta_knob_4(d)
    set_message(self.name.." "..self.name_knob_map[4].." turning "..d)
    params:delta(self.name.."_knob_4", d)
    return self.knob_4
end

function base:delta_knob_5(d)
    set_message(self.name.." "..self.name_knob_map[5].." turning "..d)
    params:delta(self.name.."_knob_5", d)
    return self.knob_5
end
function base:delta_knob_6(d)
    set_message(self.name.." "..self.name_knob_map[6].." turning "..d)
    params:delta(self.name.."_knob_6", d)
    return self.knob_6
end

return base