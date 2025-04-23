---@diagnostic disable: undefined-global, lowercase-global

local _lfos = require 'lfo'
local base = {}
base.__index = base

function base.new(args)
    local self = setmetatable({}, base)
    self.name = args.name
    self.message = ""
    self.mode = "LFO"
    self.knobs = {64,64,64,64,64,64}
    self.dm = args.dm
    self.lfos = {}
    return self
end

function base:set_message(msg, count)
    self.message = msg
    message_count = count and count or 8
    screen_dirty = true
end

function base:add_params()
    params:add_group(self.name, 8)
    --params:add_separator(self.name)
    params:add{
        type = "number", id = (self.name.."_channel"),
        name = ("channel"),
        min = 1, max = 16,
        default = self.channel,
        action = function(x) self.channel = x end
    }
    params:add{
        type = "number", id = (self.name.."_mode"),
        name = ("mode"),
        min = 1, max = 16,
        default = 1,
        action = function(x) self.mode = self.mode=="LFO" and "PAT" or "LFO" end
    }
    for i=1,6 do
        params:add_control(self.name.."_knob_"..i,self.name_knob_map[i],controlspec.MIDI)
        params:set_action(self.name.."_knob_"..i, function(x)
            self.knobs[i] = x
            mft.ind[self.mft_knob_map[i]] = x
            self.dm:device_out():cc(self.cc_knob_map[i], x, self.channel)
        end)
    end
end

function base:delta_mode()
    params:delta(self.name.."_mode",1)
end

function base:delta_knob(n,d)
    for i=1,6 do
        if n==self.mft_knob_map[i] then
            if self.lfos[i]:get('enabled') == 1 then self:delta_lfo_depth(i, d) else self:delta(i, d) end
            return
        end
    end
end

function base:delta(n, d)
    params:delta(self.name.."_knob_"..n, d)
    self:set_message(self.name_knob_map[n].." "..params:get(self.name.."_knob_"..n))
end

function base:init_lfos()
    params:add_group(self.name..' LFOs',90)
    for i=1,6 do
        table.insert(self.lfos, {})
        self.lfos[i] = _lfos:add{
            shape = 'sine',
            min = -1,
            max = 1,
            depth = 0.2, -- depth (0 to 1)
            mode = 'clocked',
            period = 4, -- (in 'clocked' mode, represents beats)
            baseline = 'center',
            --reset_target = 'mid: falling',
            action = function(scaled, raw)
                params:lookup_param(self.name.."_knob_"..i).action(self:calculate_bipolar_lfo_movement(self.lfos[i], self.name.."_knob_"..i))
                grid_dirty = true
            end -- action, always passes scaled and raw values
        }
        self.lfos[i]:add_params(self.name..'_lfo_'..i, 'lfo '..i)

        --self.lfos[i]:set('reset_target', 'mid: falling')
        --self.lfos[i]:start() -- start our LFO, complements ':stop()'
    end
end

function base:calculate_bipolar_lfo_movement(lfoID, paramID)
    if lfoID:get('depth') > 0 then
        --print(params:lookup_param(paramID).controlspec:map(lfoID:get('scaled')/2 + params:get_raw(paramID)))
        return params:lookup_param(paramID).controlspec:map(lfoID:get('scaled')/2 + params:get_raw(paramID))
    else
        return params:lookup_param(paramID).controlspec:map(params:get_raw(paramID))
    end
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

function base:delta_lfo_depth(n, d)
    local val = util.clamp(self.lfos[n]:get("depth") + (d*0.025), 0, 1)
    self:set_message("lfo depth "..self.name_knob_map[n].." "..val)
    self.lfos[n]:set("depth", val)
end

return base