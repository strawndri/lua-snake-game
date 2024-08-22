_G.love = require('love')

function love.load()
    love.graphics.setBackgroundColor(0.157, 0.165, 0.212)

    _G.gridX = 30
    _G.gridY = 25

    function moveFood()

        local possibleFoodPositions = {}

        for foodX = 1, gridX do
            for foodY = 1, gridY do
                local possible = true

                for segmentIndex, segment in ipairs(snake) do 
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end
            
                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        food = possibleFoodPositions[
            love.math.random(#possibleFoodPositions)
        ]
    end

    function reset()
        _G.snake  = {
            {x = 3, y = 1},
            {x = 2, y = 1},
            {x = 1, y = 1},
        }
        _G.directionQueue = {'right'}
        _G.timer = 0
        _G.snakeAlive = true
        moveFood()
    end
    
    reset()
end

function love.update(dt)
    timer = timer + dt
    
    if snakeAlive then
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

            local canMove = true

            for segmentIndex, segment in ipairs(snake) do
                if segmentIndex ~= #snake
                and nextPositionX == segment.x
                and nextPositionY == segment.y then
                    canMove = false
                end
            end
            
            if canMove then
                table.insert(snake, 1, {
                    x = nextPositionX,
                    y = nextPositionY
                })
                
                if snake[1].x == food.x
                and snake[1].y == food.y then
                    moveFood()
                else
                    table.remove(snake)
                end
            else 
                snakeAlive = false
            end
        end
    elseif timer >= 2 then
        reset()
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

    local function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            
            cellSize - 1,
            cellSize - 1
        )
    end
    
    for segmentIndex, segment in ipairs(snake) do
        if snakeAlive then
            love.graphics.setColor(1, 0.475, 0.776)
        else
            love.graphics.setColor(0.518, 0.537, 0.671)
        end

        drawCell(segment.x, segment.y)
    end

    love.graphics.setColor(0.314, 0.98, 0.482)
    drawCell(food.x, food.y)
end