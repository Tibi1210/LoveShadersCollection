local is_fullscreen = true
local M_x = SW/2
local M_y = SH/2
local time = 0
local current_shader = 1
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
    Shader.New("shaders/" .. Shader_files[current_shader])
end

function love.load()

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

    Shader.SetVector2("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
    Shader.SetTexture2D("uNoise", "Assets/noise.png")
    Shader.SetTexture2D("uBlueNoise", "Assets/blue-noise.png")
    Shader.SetVector2("mouse_pos", {M_x, M_y})

    love.keyboard.setKeyRepeat(true)
end

function love.update(dt)
	time = time + dt


    Shader.SetFloat("iTime",time)
    Shader.SetFloat("uFrame",uframe)
    uframe = uframe + 1
    if love.mouse.isDown(1) then
        M_x, M_y = love.mouse.getPosition()
        Shader.SetVector2("mouse_pos", {M_x, M_y})
    end
    Shader.SetBoolean("mouse_click", love.mouse.isDown(1))
    Shader.SetInteger("mouse_wheel", mousewheel)
    Shader.SetInteger("noise_type", noise_type)

end

function love.draw()
    love.graphics.setShader(Shader.Get())
    love.graphics.setColor(0,0,0)
    if Shader_files[current_shader] == "noise/planet.glsl" then
        love.graphics.circle("fill", SW/2,SH/2, SW/4,SH/4)
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
        love.window.setFullscreen(is_fullscreen)
        if not is_fullscreen then
            SW = 1000
            SH = 600
            love.load()
        else
            SW = love.graphics.getWidth()
            SH = love.graphics.getHeight()
            love.load()
        end
        is_fullscreen = not is_fullscreen
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