---@diagnostic disable: undefined-global, lowercase-global

local _lfos = require 'lfo'
local base = {}
base.__index = base

function base.new(args)
    local self = setmetatable({}, base)
    self.name = args.name
    -- pedal knobs
    self.knob_1 = 64
    self.knob_2 = 64
    self.knob_3 = 64
    self.knob_4 = 64
    self.knob_5 = 64
    self.knob_6 = 64

    self.dm = args.dm

    --lfos
    self.lfos = {}
    local knob_lfo
    params:add_group(self.name..' LFOs',90)
    for i=1,6 do
        knob_lfo = _lfos:add{
            shape = 'sine',
            min = 0,
            max = 127,
            depth = 1, -- depth (0 to 1)
            mode = 'clocked',
            period = 4, -- (in 'clocked' mode, represents beats)
            baseline = 'center',
            reset_target = 'mid: falling',
            action = function(scaled, raw)
                --print(scaled.." : "..raw)
                self:set_knob(i,math.floor(scaled+0.5))
                grid_dirty = true
            end -- action, always passes scaled and raw values
        }
        table.insert(self.lfos, knob_lfo)
        self.lfos[i]:add_params(self.name..'_lfo_'..i, 'lfo '..i)

        --self.lfos[i]:set('reset_target', 'mid: falling')
        --self.lfos[i]:start() -- start our LFO, complements ':stop()'
    end

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
    params:add_control(self.name.."_knob_1",self.name_knob_map[1],controlspec.MIDI)
    params:set_action(self.name.."_knob_1", function(x)
        self.knob_1 = x
        self.dm:device_out():cc(self.cc_knob_map[1], x, self.channel)
    end)

    params:add_control(self.name.."_knob_2",self.name_knob_map[2],controlspec.MIDI)
    params:set_action(self.name.."_knob_2", function(x)
        self.knob_2 = x
        self.dm:device_out():cc(self.cc_knob_map[2], x, self.channel)
    end)

    params:add_control(self.name.."_knob_3",self.name_knob_map[3],controlspec.MIDI)
    params:set_action(self.name.."_knob_3", function(x)
        self.knob_3 = x
        self.dm:device_out():cc(self.cc_knob_map[3], x, self.channel)
    end)

    params:add_control(self.name.."_knob_4",self.name_knob_map[4],controlspec.MIDI)
    params:set_action(self.name.."_knob_4", function(x)
        self.knob_4 = x
        self.dm:device_out():cc(self.cc_knob_map[4], x, self.channel)
    end)

    params:add_control(self.name.."_knob_5",self.name_knob_map[5],controlspec.MIDI)
    params:set_action(self.name.."_knob_5", function(x)
        self.knob_5 = x
        self.dm:device_out():cc(self.cc_knob_map[5], x, self.channel)
    end)

    params:add_control(self.name.."_knob_6",self.name_knob_map[6],controlspec.MIDI)
    params:set_action(self.name.."_knob_6", function(x)
        self.knob_6 = x
        self.dm:device_out():cc(self.cc_knob_map[6], x, self.channel)
    end)
end

function base:delta_knob(n,d)
    for i=1,6 do
        if n==self.mft_knob_map[i] then
            mft.ind[n] = self:delta(i, d)
            return
        end
    end
end

function base:delta(n, d)
    set_message(self.name.." "..self.name_knob_map[n].." turning "..d)
    params:delta(self.name.."_knob_"..n, d)
    return params:get(self.name.."_knob_"..n)
end

function base:set_knob(n,val)
    mft.ind[self.mft_knob_map[n]] = self:set(n, val)
end

function base:set(n, val)
    --set_message(self.name.." "..self.name_knob_map[1].." turning "..d)
    params:set(self.name.."_knob_"..n, val)
    return val
end

function base:toggle_lfo(n)
    for i=1,6 do
        if n==self.mft_knob_map[i] then
            if self.lfos[i]:get('enabled') == 0 then
                self.lfos[i]:start()
            else
                self.lfos[i]:stop()
            end
            return
        end
    end
end

return base