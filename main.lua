_G.love = require("love")

local fullscreen = true

local M_x = 0
local M_y = 0

local time
local shader_files = {}
local current_shader = 1
local Shader = nil
local first_load = 0

local function read_shaders()
    for file in io.popen([[dir "shaders\" /b]]):lines() do
        if string.sub(file, -5, -1) == ".glsl" then
            table.insert(shader_files, file)
        end
    end
end

local function load_shader()
    if first_load == 0 then   
        file = io.open("save.txt", "r")
        io.input(file)
        local saveState = io.read()
        io.close(file)
        for key, value in pairs(shader_files) do
            if value == saveState then
                current_shader = key
            end
        end
    end
    Shader = love.graphics.newShader("shaders/" .. shader_files[current_shader])
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
    love.window.setTitle(shader_files[current_shader])

    if Shader ~= nil and Shader:hasUniform("screen") then
        Shader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
    end
    
    if Shader ~= nil and Shader:hasUniform("uNoise") then
        local noiseTex = love.graphics.newImage("Assets/noise.png")
        noiseTex:setWrap('repeat','repeat')
        Shader:send("uNoise", noiseTex)
    end


    if Shader ~= nil and Shader:hasUniform("mouse_pos") then
        Shader:send("mouse_pos",{M_x, M_y})
    end
end

function love.update(dt)
	time = time + dt

    if Shader ~= nil and Shader:hasUniform("iTime") then
        Shader:send("iTime",time)
    end

    if love.mouse.isDown(1) then
        M_x, M_y = love.mouse.getPosition()
        --print("X: " .. M_x .. " Y: " .. M_y)
        if Shader ~= nil and Shader:hasUniform("mouse_pos") then
            Shader:send("mouse_pos",{M_x, M_y})
        end
    end
end

function love.draw()
    love.graphics.setShader(Shader)
    love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 0, 0, SW, SH)
end

function love.keypressed(key)
    if key == 'escape' then
        local file = io.open("save.txt", "w")
        io.output(file)
        io.write(shader_files[current_shader])
        io.close(file)
        love.event.quit()
    end

    if key == 'r' then
        local file = io.open("save.txt", "w")
        io.output(file)
        io.write(shader_files[current_shader])
        io.close(file)
        love.event.quit("restart")
    end

    if key == 'space' then
        current_shader = current_shader + 1
        if current_shader > #shader_files then
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

end