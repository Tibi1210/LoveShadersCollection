
SW = 1000
SH = 600

function love.conf(t)
    t.window.title = "ShaderToy"

    t.window.height = SH
    t.window.width = SW
    t.window.resizable = false

    t.console = false

    t.window.borderless = true
end