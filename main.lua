_G.love = require("love")

local fullscreen = true

local time
local shader_files = {}
local current_shader = 1

local function read_shaders()
    for file in io.popen([[dir "shaders\" /b]]):lines() do
        if string.sub(file, -5, -1) == ".glsl" then
            table.insert(shader_files, file) 
        end        
    end
end

function love.load()
    --love.window.setPosition( 900, 200, 1 )
    time = 0
    read_shaders()
    love.window.setTitle(shader_files[current_shader]) 
    Shader = love.graphics.newShader("shaders/" .. shader_files[current_shader])
    Shader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})

end
 

function love.update(dt)
	time = time + dt

    if Shader:hasUniform("iTime") then
        Shader:send("iTime",time)
    end
end

function love.draw()
    love.graphics.setShader(Shader)
	love.graphics.rectangle("fill", 0, 0, SW, SH)
    love.graphics.setShader()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'r' then
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