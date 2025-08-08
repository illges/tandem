-- control fx pedals in tandem

---@diagnostic disable: undefined-global, lowercase-global, duplicate-set-field

SCRIPT_NAME = "tandem"
local _grid = include 'lib/_grid'
local _blooper = include 'lib/blooper'
local _mood = include 'lib/mood'
local _dm = include 'device_manager/lib/_device_manager' -- install from https://github.com/illges/device_manager
local _pacifist = include 'pacifist_dev/lib/_pacifist' -- install from https://github.com/illges/pacifist_dev

engine.name = 'PolyPerc'

message_count = 0

function init()
    message = SCRIPT_NAME
    dm = _dm.new({adv=false, debug=false})
    pedal1=_mood.new({dm=dm})
    pedal2=_blooper.new({dm=dm})
    mft = _pacifist:new({
        devices=dm.devices, debug=false, colors={pedal1.color,pedal1.color,pedal1.color,0,pedal1.color,pedal1.color,pedal1.color,0,0,pedal2.color,pedal2.color,pedal2.color,0,pedal2.color,pedal2.color,pedal2.color},
        ind={pedal1.knobs[1],pedal1.knobs[2],pedal1.knobs[3],0,pedal1.knobs[4],pedal1.knobs[5],pedal1.knobs[6],0,0,pedal2.knobs[1],pedal2.knobs[2],pedal2.knobs[3],0,pedal2.knobs[4],pedal2.knobs[5],pedal2.knobs[6]}
    })
    g=_grid:new()

    screen_dirty = true
    grid_dirty = true
    screen_redraw_clock()
    grid_redraw_clock()
end

function screen_redraw_clock()
    screen_drawing=metro.init()
    screen_drawing.time=0.1
    screen_drawing.count=-1
    screen_drawing.event=function()
        if message_count>0 then
            message_count=message_count-1
        else
            -- pedal1.message = ""
            -- pedal2.message = ""
            -- screen_dirty = true
        end
        if screen_dirty == true then
            redraw()
            screen_dirty = false
        end
    end
    screen_drawing:start()
end

function set_message(msg, count)
    message = msg
    message_count = count and count or 8
    screen_dirty = true
end

function grid_redraw_clock()
    grid_drawing=metro.init()
    grid_drawing.time=0.1
    grid_drawing.count=-1
    grid_drawing.event=function()
        mft:activity_countdown()
        if grid_dirty == true then
            g:grid_redraw()
            redraw_mft()
            grid_dirty = false
        end
    end
    grid_drawing:start()
end

function enc(e, d)
    if e == 1 then turn(e, d) end
    if e == 2 then turn(e, d) end
    if e == 3 then turn(e, d) end
    screen_dirty = true
end

function turn(e, d)
    --set_message("encoder " .. e .. ", delta " .. d)
end

function key(k, z)
    if z == 0 then return end
    if k == 2 then press_down(2) end
    if k == 3 then press_down(3) end
    screen_dirty = true
end

function press_down(i)
    --set_message("press down " .. i)
end

function redraw()
    local mode_feedback = ""
    screen.clear()
    screen.aa(1)
    screen.font_face(1)
    screen.font_size(8)
    screen.level(15)

    -- split screen
    screen.move(0, 32)
    screen.line(127,32)
    screen.stroke()

    screen.level(15)
    screen.move(0, 5)
    screen.text(pedal1.name.."-".. pedal1.mode )
    draw_pedal(pedal1)

    screen.level(15)
    screen.move(127, 62)
    screen.text_right(pedal2.mode.."-"..pedal2.name)
    draw_pedal(pedal2)

    screen.fill()
    screen.update()
end

function draw_pedal(pedal)
    local mode_feedback = ""
    for i=1,6 do
        screen.level(mft:active_turned(pedal.mft_knob_map[i]) and 10 or 4)
        mode_feedback = pedal:lfo_is_enabled(i) and "^" or ""
        screen.move(pedal.display_x_map[i], pedal.display_y_map[i])
        screen.text(pedal.short_names_map[i]..mode_feedback)

        screen.level(2)
        screen.move(pedal.display_x_map[i] + pedal.display_x_offset_map[i], pedal.display_y_map[i])
        screen.text(pedal:lfo_is_enabled(i) and pedal.knob_lfo_vals[i] or pedal.knobs[i])
    end
end

function redraw_mft()
    --mft:all(0)
    for i=1,16 do
        mft:led(i, mft.color[i]) --color is optional
        mft:send(i, mft.ind[i])
    end
end

function mft_enc(n,d)
    mft:track_turned(n,15,15)
    --mft:delta_color(n,d)
    if mft.momentary[n] == 1 then -- knob is pressed
        mft.turned_while_pressed[n] = 1
        -- if lfo on then update real val
        -- else update real value on release
    else
        if (n>=1 and n<=3) or (n>=5 and n<=7) then
            pedal1:delta_knob(n,d)
        elseif (n>=10 and n<=12) or (n>=14 and n<=16) then
            pedal2:delta_knob(n,d)
        end
    end
    screen_dirty = true
    grid_dirty=true
end

function mft_key(n,z)
    local on = z==1
    mft.momentary[n] = on and 1 or 0
    if on then
        mft:track_pressed(n,15,15)
        if (n>=1 and n<=3) or (n>=5 and n<=7) then
            
        elseif (n>=10 and n<=12) or (n>=14 and n<=16) then
            
        elseif n==17 then
            pedal1:delta_mode()
        elseif n==18 then
        elseif n==19 then
            dm:device_out():program_change(1, pedal1.channel)
        elseif n==20 then
            pedal2:delta_mode()
        elseif n==21 then
        elseif n==22 then
            dm:device_out():program_change(1, pedal2.channel)
        end
    else
        if (n>=1 and n<=3) or (n>=5 and n<=7) then
            if mft.turned_while_pressed[n] == 0 then
                pedal1:toggle_lfo(n)
            end
        elseif (n>=10 and n<=12) or (n>=14 and n<=16) then
            if mft.turned_while_pressed[n] == 0 then
                pedal2:toggle_lfo(n)
            end
        elseif 17 then
        elseif 18 then
        elseif 19 then
        elseif 20 then
        elseif 21 then
        elseif 22 then
        end
        mft.turned_while_pressed[n] = 0
    end
    screen_dirty = true
    grid_dirty=true
end

function midi_event_note_on(d)
    --set_message(d.note)
end

function midi_event_note_off(d) end

function midi_event_start(d) end

function midi_event_stop(d) end

function midi_event_cc(d) end

function r() ----------------------------- execute r() in the repl to quickly rerun this script
    norns.script.load(norns.state.script) -- https://github.com/monome/norns/blob/main/lua/core/state.lua
end

function cleanup() --------------- cleanup() is automatically called on script close

end