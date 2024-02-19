_G.love = require("love")

local time

local shader_files = {
    "SAMPLE",
    "lights",
    "mandel",
    "winter"
}
local current_shader = 1



function love.load()
    --love.window.setPosition( 900, 200, 1 )
    time = 0
    Shader = love.graphics.newShader(shader_files[current_shader] .. ".glsl")
    Shader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
end
 
 function love.update(dt)
	time = time + dt

    if current_shader > 1 then 
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
end