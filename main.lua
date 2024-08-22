_G.love = require('love')

function love.load()
    love.graphics.setBackgroundColor(0.157, 0.165, 0.212)

    _G.gridX = 30
    _G.gridY = 25

    _G.snake  = {
        {x = 3, y = 1},
        {x = 2, y = 1},
        {x = 1, y = 1},
    }
    
    _G.directionQueue = {'right'}
    
    _G.timer = 0
end

function love.update(dt)
    timer = timer + dt
    
    if timer >= 0.15 then
        timer = 0
        
        if #directionQueue > 1 then
            table.remove(directionQueue, 1)
        end
        
        local nextPositionX = snake[1].x
        local nextPositionY = snake[1].y

        if directionQueue[1] == 'right' then
            nextPositionX = nextPositionX + 1
            if nextPositionX > gridX then
                nextPositionX = 1
            end

        elseif directionQueue[1] == 'left' then
            nextPositionX = nextPositionX - 1
            if nextPositionX < 1 then
                nextPositionX = gridX
            end

        elseif directionQueue[1] == 'up' then
            nextPositionY = nextPositionY - 1
            if nextPositionY < 1 then
                nextPositionY = gridY
            end

        elseif directionQueue[1] == 'down' then
            nextPositionY = nextPositionY + 1
            if nextPositionY > gridY then
                nextPositionY = 1
            end
        end
        
        table.insert(snake, 1, {
            x = nextPositionX,
            y = nextPositionY
        })
        
        table.remove(snake)
    end
end

function love.keypressed(key)
    if key == 'right' 
    and directionQueue[#directionQueue] ~= 'right'
    and directionQueue[#directionQueue] ~= 'left' then
        table.insert(directionQueue, 'right')
        
    elseif key == 'left' 
    and directionQueue[#directionQueue]  ~= 'left'
    and directionQueue[#directionQueue]  ~= 'right' then
        table.insert(directionQueue, 'left')
        
    elseif key == 'up' 
    and directionQueue[#directionQueue]  ~= 'up'
    and directionQueue[#directionQueue]  ~= 'down' then
        table.insert(directionQueue, 'up')
        
    elseif key == 'down' 
    and directionQueue[#directionQueue]  ~= 'down'
    and directionQueue[#directionQueue]  ~= 'up' then
        table.insert(directionQueue, 'down')
    end
end

function love.draw()
    
    local cellSize = 20
    
    for segmentIndex, segment in ipairs(snake) do
        love.graphics.setColor(1, 0.475, 0.776)
        love.graphics.rectangle(
            'fill',
            (segment.x - 1) * cellSize,
            (segment.y - 1) * cellSize,
            
            cellSize - 1,
            cellSize - 1
        )
    end
end