_G.love = require("love")

local time
local shader_files = {}
local current_shader = 1

local function read_shaders()
    for file in io.popen([[dir "shaders\" /b]]):lines() do table.insert(shader_files, file) end
end

function love.load()
    --love.window.setPosition( 900, 200, 1 )
    time = 0
    read_shaders()
    Shader = love.graphics.newShader("shaders/" .. shader_files[current_shader])
    Shader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
    
end
 
local function conditional_GPU_calls()
    Shader:send("iTime",time)
end

function love.update(dt)
	time = time + dt

    if pcall(conditional_GPU_calls) then  end
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
end