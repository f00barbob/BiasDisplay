require("stringy")
local mouse_was_down = false
local accumulate = 0
local window_height = 210
local window_width = 224 --supposed to be 224

local debugme = true

local buttons = {0,0,0,0,0,0,0}
local holds   = {0,0,0,0,0,0,0}
local buttons_tot = 0
local holds_tot = 0
local cleartimer = 300

local lastbias = "POTATO"

inpts = {}
inpts[1] = "left"
inpts[2] = "down"
inpts[3] = "up"
inpts[4] = "right"
inpts[5] = "A"
inpts[6] = "B"
inpts[7] = "start"

font = love.graphics.newFont(22)

lastinpts1 = {}
lastinpts5 = {}
lastinpts15 = {}




function love.load()
	love.graphics.setFont(font)
	love.window.setMode(window_width,window_height,{vsync=false})
	love.window.setTitle("RNGBiasDisplay")
	-- spawn the netthread
	print("spawning networking thread")
	netthread = love.thread.newThread("netthread.lua")
	netchannel = love.thread.getChannel("netchan")
	netthread:start()
	inbound = {}
    cnv_squiggles = love.graphics.newCanvas(801, 801)
    cnv_squiggles_buffer = love.graphics.newCanvas(801, 801)
    cnv_squiggles:setWrap("repeat", "repeat")
    cnv_squiggles_buffer:setWrap("repeat", "repeat")
    cnv_background = love.graphics.newCanvas(210,224)
    --love.graphics.setBackgroundColor(100,100,100,0)
    img_fade = love.graphics.newImage("fade.png") 
    img_fade_hard = love.graphics.newImage("fade_hard.png") 
    img_color_ring = love.graphics.newImage("colorring.png") 
    img_color_ring_add = love.graphics.newImage("colorringadd.png") 
end

function love.update(dt)
    accumulate = accumulate + dt


    if accumulate  > .04 then
        if auto and scrolling then
            do_randy()
        end
        accumulate = 0
    end

    command = "nil"
    cmdval  = "nil"
    netmsg = netchannel:pop()



    if netmsg ~= nil then
        foo = netmsg:split(":")
        command = foo[1]
        cmdval = foo[2]
        cmdvalnum = tonumber(cmdval)
    end


    if netmsg ~= nil
    and command ~= nil
    and cmdvalnum ~= nil
    and cmdvalnum >= 0 
    and cmdvalnum <= 6 then
        buttons_tot = buttons_tot + 1
        buttons[cmdvalnum + 1] = buttons[cmdvalnum + 1] + 1
    if command == "HOLD" then
        holds_tot = holds_tot + 1
        holds[cmdvalnum + 1] = holds[cmdvalnum + 1] + 1
    end

    if command == "HOLD"
    or command == "PRESS" then
        draw_squiggles(cmdvalnum)
    end 

    end
    if command == "SETBIAS" then
        print("setbias!" .. cmdval)
        love.graphics.setCanvas(cnv_squiggles)
        love.graphics.print("BIAS:" .. cmdval, 400,400)
        love.graphics.setCanvas()
        lastbias = cmdval

    elseif command == "DODECAY" then
        love.graphics.setCanvas(cnv_squiggles)
        love.graphics.print("DODECAY!" , 400,400)
        love.graphics.setCanvas()
        
    elseif command == "KAPPA" then
        
    end
    
    if love.mouse.isDown("r") == true then
        do_randy()
    end
  
    if love.keyboard.isDown("r") == true then
        buttons = {0,0,0,0,0,0,0}
        holds   = {0,0,0,0,0,0,0}
        buttons_tot = 0
        holds_tot = 0

    end

  
    if love.keyboard.isDown("1") then
        draw_squiggles(0)
    elseif love.keyboard.isDown("2") then
        draw_squiggles(1)
    elseif love.keyboard.isDown("3") then
        draw_squiggles(2)
    elseif love.keyboard.isDown("4") then
        draw_squiggles(3)
    end
end

function love.keypressed(key)
    if 	key == "a" then
        animated = not animated
    elseif 	key == "d" then
        debugme = not debugme
    end
end


function love.draw()

    love.graphics.setStencil(teh_stencil)
    love.graphics.draw(cnv_background)
    love.graphics.setStencil()

    love.graphics.circle("line",112,105,103)
    love.graphics.line(112,0,112,210)
    love.graphics.line(0,105,224,105)

    love.graphics.setColor(0,0,0,128)
    love.graphics.rectangle('fill',0,0,224,30)
    love.graphics.setColor(100,100,100,255)
    love.graphics.rectangle('line',0,0,224,30)
    love.graphics.setColor(255,255,255,255)
    love.graphics.printf("Bias: " .. lastbias, 0,0,224, 'center')

    if debugme == true then	draw_debug() end

end

function love.threaderror(thread, errortext)
    error(errortext) -- Makes sure any errors that happen in the thread are displayed onscreen.
end

function teh_stencil()
  love.graphics.circle("fill",112,105,103)
end

function draw_squiggles(direction)

    offset_x = 0
    offset_y = 0
    if direction == 0 then
        offset_x = 1
    elseif direction == 1 then
        offset_y = -1
    elseif direction == 2 then
        offset_y = 1
    elseif direction == 3 then
        offset_x = -1
    else 
        return
    end
    
    --love.graphics.setColor(math.random(5) + 250, 255,math.random(5) + 250,254)
    love.graphics.setColor(255,255,255,254)

    love.graphics.setCanvas(cnv_squiggles_buffer)
    cnv_squiggles_buffer:clear(0,0,0,0)
    cnv_background:clear(0,0,0,0)
    love.graphics.draw(cnv_squiggles, offset_x, offset_y)
    love.graphics.draw(cnv_squiggles, offset_x, offset_y)

    cnv_squiggles:clear(0,0,0,0)

    love.graphics.setCanvas(cnv_squiggles)
        love.graphics.draw(cnv_squiggles_buffer)
    
    love.graphics.setColor(255,255,255,255)

    love.graphics.rectangle("fill",399, 392, 2, 2)

    love.graphics.setBlendMode("subtractive")
        love.graphics.setColor(145,145,145,1)
            love.graphics.draw(img_color_ring)

    love.graphics.setBlendMode("additive")
        love.graphics.setColor(55,55,55,1)
            love.graphics.draw(img_color_ring_add)

    love.graphics.setBlendMode("alpha")
        love.graphics.setColor(255,255,255,2)
            love.graphics.draw(img_fade)

    love.graphics.setColor(255,255,255,128)
        love.graphics.draw(img_fade_hard)

    love.graphics.setColor(255,255,255,255)
    love.graphics.setCanvas()
    love.graphics.setCanvas(cnv_background)
        love.graphics.draw(cnv_squiggles,-288,-288)
        
    love.graphics.setCanvas()
end

function draw_debug()
  	for i = 1, 7 do
		local current_tot = buttons[i]
    local current_htot = holds[i]
		local procent = buttons[i] / buttons_tot * 100
    local hprocent = holds[i] / holds_tot * 100
    local hpprocent = holds[i] / buttons[i]* 100
  	love.graphics.print(inpts[i] .. ":",10,15*i+224)
    love.graphics.print(string.format("%i\t%15.2f%%",current_tot,procent),60,15*i +224 )
    --love.graphics.print(string.format("%i:%i\t%15.2f%%\t%15.2f%%",i,current_htot,hprocent,hpprocent),160,15*i +224)
	end

	
end

function do_randy(...)
	local action = arg[0] or nil
	-- i'm feeling randy, baby
	spawn_y = canvas_height
	local randy = math.random(0,4)
  draw_squiggles(randy)

end



function render_button_display()
	cnv_buttons:clear()
	for i, b in ipairs(buttons) do
		draw_button(b.sprite, b.x, b.y, b.rot, b.alpha)
	end
end





