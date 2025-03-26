---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/pedal'

local blooper = setmetatable({}, {__index = base})
blooper.__index = blooper

function blooper.new(args)
    local self = setmetatable(base.new(args), blooper)
    return self
end

function base:delta(n,d)
    if n==10 then return self:delta_time(d)
    elseif n==11 then return self:delta_mix(d)
    elseif n==12 then return self:delta_length(d)
    elseif n==14 then return self:delta_mod_1(d)
    elseif n==15 then return self:delta_clock(d)
    elseif n==16 then return self:delta_mod_2(d)
    end
end

return blooper