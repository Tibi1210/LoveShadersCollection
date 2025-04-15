_G.love = require("love")

local fullscreen = true

local M_x = SW/2
local M_y = SH/2

local time = 0
local current_shader = 1
local Shader = nil
local first_load = 0
local uframe = 0
local mousewheel = 1

local noise_type = 0

local function read_shaders()
    Shader_files = {}
    for _, subdir in pairs(love.filesystem.getDirectoryItems("shaders/")) do
        for _, file in pairs(love.filesystem.getDirectoryItems("shaders/"..subdir)) do
            if string.sub(file, -5, -1) == ".glsl" then
                table.insert(Shader_files, subdir.."/"..file)
            end
        end
    end
end

local function load_shader()
    if first_load == 0 then
        local saveState = love.filesystem.read("save.txt")
        for key, value in pairs(Shader_files) do
            if value == saveState then
                current_shader = key
            end
        end
    end
    Shader = love.graphics.newShader("shaders/" .. Shader_files[current_shader])
end

function love.load()
    Shader = nil
    --love.window.setPosition( 900, 200, 1 )
    time = 0
    read_shaders()
    
    local load_status, load_err = pcall(load_shader)
    if not load_status then
        print(load_err .. "\n")
    end
    first_load = 1
    love.window.setTitle(Shader_files[current_shader])

    M_x = SW/2
    M_y = SH/2

    if Shader ~= nil and Shader:hasUniform("screen") then
        Shader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
    end
    
    if Shader ~= nil and Shader:hasUniform("uNoise") then
        local blue_noiseTex = love.graphics.newImage("Assets/blue-noise.png")
        local noiseTex = love.graphics.newImage("Assets/noise.png")
        blue_noiseTex:setWrap('repeat','repeat')
        noiseTex:setWrap('repeat','repeat')
        noiseTex:setFilter("linear", "linear")
        blue_noiseTex:setFilter("linear", "linear")
        Shader:send("uNoise", noiseTex)
        Shader:send("uBlueNoise", blue_noiseTex)
    end

    if Shader ~= nil and Shader:hasUniform("mouse_pos") then
        --print("X: " .. M_x .. " Y: " .. M_y)
        Shader:send("mouse_pos",{M_x, M_y})
    end
    
    if Shader ~= nil and Shader:hasUniform("mouse_click") then
        Shader:send("mouse_click", love.mouse.isDown(1))
    end

    if Shader ~= nil and Shader:hasUniform("noise_type") then
        Shader:send("noise_type", noise_type)
    end

    love.keyboard.setKeyRepeat(true)
end

function love.update(dt)
	time = time + dt

    if Shader ~= nil and Shader:hasUniform("iTime") then
        Shader:send("iTime",time)
    end
    
    if Shader ~= nil and Shader:hasUniform("uFrame") then
        Shader:send("uFrame", uframe)
        uframe = uframe + 1
    end

    if Shader ~= nil and Shader:hasUniform("mouse_pos") and love.mouse.isDown(1) then
        M_x, M_y = love.mouse.getPosition()
        --print("X: " .. M_x .. " Y: " .. M_y)
        Shader:send("mouse_pos",{M_x, M_y})
    end

    if Shader ~= nil and Shader:hasUniform("mouse_click") then
        Shader:send("mouse_click", love.mouse.isDown(1))
    end

    if Shader ~= nil and Shader:hasUniform("noise_type") then
        Shader:send("noise_type", noise_type)
    end

    if Shader ~= nil and Shader:hasUniform("mouse_wheel") then
        Shader:send("mouse_wheel", mousewheel)
    end
end

function love.draw()
    love.graphics.setShader(Shader)
    love.graphics.setColor(0,0,0)
    if Shader_files[current_shader] == "noise/planet.glsl" then
        love.graphics.circle("fill", SW/2,SH/2, 100, 100)
    else
        love.graphics.rectangle("fill", 0, 0, SW, SH)
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        mousewheel = mousewheel - 1
        if mousewheel < 2 then
            mousewheel = 1
        end
    elseif y < 0 then
        mousewheel = mousewheel + 1
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.filesystem.write("save.txt", Shader_files[current_shader])
        love.event.quit()
    end

    if key == 'r' then
        love.filesystem.write("save.txt", Shader_files[current_shader])
        love.event.quit("restart")
    end

    if key == 'space' then
        current_shader = current_shader + 1
        if current_shader > #Shader_files then
            current_shader = 1
        end
        love.load()
      end

    if key == 'f' then
        love.window.setFullscreen(fullscreen)
        if not fullscreen then
            SW = 1000
            SH = 600
            love.load()
        else
            SW = love.graphics.getWidth()
            SH = love.graphics.getHeight()
            love.load()
        end
        fullscreen = not fullscreen
    end

    if key == 'tab' then
        if Shader_files[current_shader] == "noise/noise_types.glsl" then
            if noise_type < 2 then
                noise_type = noise_type + 1
            else
                noise_type = 0
            end

            if noise_type == 0 then
                love.window.setTitle(Shader_files[current_shader] .. " type: Perlin")
            elseif noise_type == 1 then
                love.window.setTitle(Shader_files[current_shader] .. " type: Value")
            else
                love.window.setTitle(Shader_files[current_shader] .. " type: Simplex")
            end
        end

    end

end