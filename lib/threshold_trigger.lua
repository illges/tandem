---@diagnostic disable: undefined-global, lowercase-global

local base = {}
base.__index = base

function base.new(args)
    local self = setmetatable({}, base)
    self.debug = args.debug
    self.cc = args.cc
    self.value = args.value
    self.channel = args.channel
    self.armed = 0
    self.amp_in = {}
    self.amp_out = {}
    self.targets = {"input", "output"}
    self.target_selection = 1

    self:init()
    return self
end

function base:init()
    self:amp_setup(self.amp_in, "in")
    self:amp_setup(self.amp_out, "out")
end

function base:amp_setup(amp, dir)
    local amp_src = {"amp_"..dir.."_l", "amp_"..dir.."_r"}
    amp.name = dir
    for ch = 1, 2 do
        amp[ch] = poll.set(amp_src[ch])
        amp[ch].time = 0.01
        amp[ch].callback = function(val)
            if val > util.dbamp(-12) / 10 then
                self:print(amp_src[ch].." value: "..val)
                self:exec_event()
                amp[ch]:stop()
            end
        end
        self:print(amp_src[ch].." setup")
    end
end

function base:exec_event()
    if self.armed == 1 then
        self.armed = 0
        execute_threshold_trigger() -- add global function to script
    end
end

function base:toggle_threshold_trigger()
    local amp = self.targets[self.target_selection] == self.targets[1] and self.amp_in or self.amp_out
    if self.armed == 0 then self:arm_threshold_trigger(amp)
    else self:disarm_threshold_trigger(amp)
    end
end

function base:arm_threshold_trigger(amp)
    self:print("ARMED "..amp.name)
    self.armed = 1
    amp[1]:start()
    amp[2]:start()
end

function base:disarm_threshold_trigger(amp)
    self:print("DISARMED "..amp.name)
    self.armed = 0
    amp[1]:stop()
    amp[2]:stop()
end

function base:print(message)
    if self.debug then
        print(message)
    end
end

function base:cleanup()
    -- melt our polls
    for ch=1,2 do
        self.amp_in[ch]:stop()
        self.amp_out[ch]:stop()
    end
end

-- add global function to script
-- function execute_threshold_trigger() end

return base