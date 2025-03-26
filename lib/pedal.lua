---@diagnostic disable: undefined-global, lowercase-global

local base = {}
base.__index = base

local TIME=1; local MIX=2; local LENGTH=3;
local MOD_1=5; local CLOCK=6; local MOD_2=7;

function base.new(args)
    local self = setmetatable({}, base)
    self.name = args.name
    self.channel = args.channel
    self.cc_num_map = {14,15,16,0,17,18,19,0}

    -- mood knobs
    self.time = 64
    self.mix = 64
    self.length = 64
    self.mod_1 = 64
    self.clock = 64
    self.mod_2 = 64

    self.dm = args.dm
    self:add_params()
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
        type = "number", id = (self.name.."_time"),
        name = ("time"),
        min = 0, max = 127,
        default = self.time,
        action = function(x)
            self.time = x
            self.dm:device_out():cc(self.cc_num_map[TIME], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_mix"),
        name = ("mix"),
        min = 0, max = 127,
        default = self.mix,
        action = function(x)
            self.mix = x
            self.dm:device_out():cc(self.cc_num_map[MIX], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_length"),
        name = ("length"),
        min = 0, max = 127,
        default = self.length,
        action = function(x)
            self.length = x
            self.dm:device_out():cc(self.cc_num_map[LENGTH], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_mod_1"),
        name = ("mod_1"),
        min = 0, max = 127,
        default = self.mod_1,
        action = function(x)
            self.mod_1 = x
            self.dm:device_out():cc(self.cc_num_map[MOD_1], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_clock"),
        name = ("clock"),
        min = 0, max = 127,
        default = self.clock,
        action = function(x)
            self.clock = x
            self.dm:device_out():cc(self.cc_num_map[CLOCK], x, self.channel)
        end
    }
    params:add{
        type = "number", id = (self.name.."_mod_2"),
        name = ("mod_2"),
        min = 0, max = 127,
        default = self.mod_2,
        action = function(x)
            self.mod_2 = x
            self.dm:device_out():cc(self.cc_num_map[MOD_2], x, self.channel)
        end
    }
end

function base:delta(n,d)
    if n==1 then return self:delta_time(d)
    elseif n==2 then return self:delta_mix(d)
    elseif n==3 then return self:delta_length(d)
    elseif n==5 then return self:delta_mod_1(d)
    elseif n==6 then return self:delta_clock(d)
    elseif n==7 then return self:delta_mod_2(d)
    end
end

function base:delta_time(d)
    params:delta(self.name.."_time", d)
    return self.time
end

function base:delta_mix(d)
    params:delta(self.name.."_mix", d)
    return self.mix
end

function base:delta_length(d)
    params:delta(self.name.."_length", d)
    return self.length
end

function base:delta_mod_1(d)
    params:delta(self.name.."_mod_1", d)
    return self.mod_1
end

function base:delta_clock(d)
    params:delta(self.name.."_clock", d)
    return self.clock
end
function base:delta_mod_2(d)
    params:delta(self.name.."_mod_2", d)
    return self.mod_2
end

return base