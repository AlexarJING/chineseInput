local input=require("chineseinput")
local font = love.graphics.newFont("chinese.ttf", 12)
love.graphics.setFont(font)


function love.load()
    input.enable=true
end

function love.keypressed(key)
	input:update(key)
end

function love.draw()
   input:draw()
end