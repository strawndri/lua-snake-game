_G.love = require('love')

function love.load()
    love.graphics.setBackgroundColor(0.157, 0.165, 0.212)

    _G.gridX = 30
    _G.gridY = 25

    _G.colorPalette = {
        {1, 0.333, 0.333}, -- vermelho
        {1, 0.722, 0.424}, -- laranja
        {0.945, 0.98, 0.549}, -- amarelo
        {0.314, 0.98, 0.482}, -- verde
        {0.545, 0.914, 0.992}, -- azul
        {0.741, 0.576, 0.976}, -- roxo
        {1, 0.475, 0.776}, -- rosa
    }    

    _G.gameState = 'start'
    
    _G.images = {
        love.graphics.newImage('images/start.png'),
        love.graphics.newImage('images/gameOver.png'),
    }

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

        food.color = colorPalette[currentColorIndex]

        currentColorIndex = currentColorIndex + 1
        if currentColorIndex > #colorPalette then
            currentColorIndex = 1
        end

    end

    function reset()
        _G.snake  = {
            {x = 4, y = 1, color = colorPalette[1]},
            {x = 3, y = 1, color = colorPalette[1]},
            {x = 2, y = 1, color = colorPalette[1]},
            {x = 1, y = 1, color = colorPalette[1]},
        }
        _G.directionQueue = {'right'}
        _G.timer = 0
        _G.snakeAlive = true
        _G.currentColorIndex = 4
        moveFood()
    end
    
    reset()
end

function love.update(dt)
    timer = timer + dt
    
    if gameState == 'playing' then
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
                        snakeAlive = false
                    end
                end
    
                
                if canMove then
                    local newColor = snake[1].color
    
                    table.insert(snake, 1, {
                        x = nextPositionX,
                        y = nextPositionY,
                        color = snake[1].color
                    })
                    
                    if snake[1].x == food.x
                    and snake[1].y == food.y then
                        snake[1].color = food.color
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
            gameState = 'gameOver'
        end
    end
end

function love.keypressed(key)

    if key == 'return' and gameState == 'start' then
        gameState = 'playing'

    elseif key == 'return' and gameState == 'gameOver' then
        reset()
        gameState = 'playing'

    elseif key == 'right' 
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

    if gameState == 'start' then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            'Aperte ENTER para iniciar', 
            0, 
            love.graphics.getHeight() / 2 + 80, 
            love.graphics.getWidth(), 
            "center"
        )
        love.graphics.draw(
            images[1], 
            (love.graphics.getWidth() - images[1]:getWidth()) / 2, 
            (love.graphics.getHeight() - images[1]:getHeight() - 120) / 2
        )
    
    elseif gameState == 'playing' then
        for segmentIndex, segment in ipairs(snake) do
            if snakeAlive then
                love.graphics.setColor(segment.color)
            else
                love.graphics.setColor(0.518, 0.537, 0.671)
            end

            drawCell(segment.x, segment.y)
        end
        
        love.graphics.setColor(food.color)
        drawCell(food.x, food.y)
    
    elseif gameState == 'gameOver' then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            'GAME OVER! Aperte ENTER para reiniciar', 
            0, 
            love.graphics.getHeight() / 2, 
            love.graphics.getWidth(), 
            "center"
        )
        love.graphics.draw(
            images[2], 
            (love.graphics.getWidth() - images[2]:getWidth()) / 2, 
            (love.graphics.getHeight() - images[2]:getHeight() - 120) / 2
        )
    end
end