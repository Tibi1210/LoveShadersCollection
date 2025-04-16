local shader_handler = {}

local shader_instance = nil

function shader_handler.New(path)
    shader_instance = love.graphics.newShader(path)
end

function shader_handler.Get()
    if shader_instance then
        return shader_instance
    end
end

function shader_handler.SetFloat(uniform, value)
    if shader_instance ~= nil and shader_instance:hasUniform(uniform) then
        shader_instance:send(uniform, value)
    end
end

function shader_handler.SetInteger(uniform, value)
    if shader_instance ~= nil and shader_instance:hasUniform(uniform) then
        shader_instance:send(uniform, math.floor(value))
    end
end

function shader_handler.SetBoolean(uniform, value)
    if shader_instance ~= nil and shader_instance:hasUniform(uniform) then
        shader_instance:send(uniform, value)
    end
end

function shader_handler.SetVector2(uniform, vec2)
    if shader_instance ~= nil and shader_instance:hasUniform(uniform) then
        if #vec2 == 2 then
            shader_instance:send(uniform, vec2)
        else
            error("Shader uniform Vector2 expected, got Vector" .. #vec2)
        end
    end
end

function shader_handler.SetTexture2D(uniform, image, wrap, filter)
    wrap = wrap or 'repeat'
    filter = filter or 'linear'
    if shader_instance ~= nil and shader_instance:hasUniform(uniform) then
        local tex = love.graphics.newImage(image)
        tex:setWrap(wrap, wrap)
        tex:setFilter(filter, filter)
        shader_instance:send(uniform, tex)
    end
end

return shader_handler
