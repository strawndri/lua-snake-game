_G.love = require('love')

function love.load()
    love.graphics.setBackgroundColor(0.157, 0.165, 0.212)

    _G.gridX = 30
    _G.gridY = 25

    -- estado inicial do jogo
    _G.gameState = 'start'

    _G.colorPalette = {
        {1, 0.333, 0.333}, -- vermelho
        {1, 0.722, 0.424}, -- laranja
        {0.945, 0.98, 0.549}, -- amarelo
        {0.314, 0.98, 0.482}, -- verde
        {0.545, 0.914, 0.992}, -- azul
        {0.741, 0.576, 0.976}, -- roxo
        {1, 0.475, 0.776}, -- rosa
    }    

    _G.images = {
        love.graphics.newImage('images/start.png'),
        love.graphics.newImage('images/gameOver.png'),
    }

    -- função para mover a comida para uma nova posição aleatória
    function moveFood()
        local possibleFoodPositions = {}

        -- verifica todas as posições possíveis
        for foodX = 1, gridX do
            for foodY = 1, gridY do
                local possible = true

                -- impede que a comida apareça onde a cobra está
                for segmentIndex, segment in ipairs(snake) do 
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end

                -- adiciona as posições possíveis para a comida na lista
                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        -- seleciona aleatoriamente uma nova posição pra comida
        food = possibleFoodPositions[
            love.math.random(#possibleFoodPositions)
        ]

        -- altera a cor da comida atual
        food.color = colorPalette[currentColorIndex]

        -- avança para a próxima cor da paleta
        currentColorIndex = currentColorIndex + 1
        if currentColorIndex > #colorPalette then
            currentColorIndex = 1
        end

    end

    -- função para redefinir o jogo
    function reset()
        _G.snake  = {
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

            -- verifica se o temporizador atingiu o intervalo de movimento
            if timer >= 0.15 then
                timer = 0
                
                -- remove direções antigas da fila de direção
                if #directionQueue > 1 then
                    table.remove(directionQueue, 1)
                end

                -- define as direções de movimento da cobra
                local directions = {
                    right = {x = 1, y = 0},
                    left = {x = -1, y = 0},
                    up = {x = 0, y = -1},
                    down = {x = 0, y = 1}
                }
                
                -- nova posição da cobra
                local nextPositionX = snake[1].x
                local nextPositionY = snake[1].y

                nextPositionX = nextPositionX + directions[directionQueue[1]].x
                nextPositionY = nextPositionY + directions[directionQueue[1]].y
                
                -- implementa a movimentação da cobra através da borda da tela
                if nextPositionX > gridX then
                    nextPositionX = 1
                end
    
                if nextPositionX < 1 then
                    nextPositionX = gridX
                end
    
                if nextPositionY < 1 then
                    nextPositionY = gridY
                end
    
                if nextPositionY > gridY then
                    nextPositionY = 1
                end
    
                local canMove = true
                
                -- verifica se houve colisão da cobra com ela mesma
                for segmentIndex, segment in ipairs(snake) do
                    if segmentIndex ~= #snake
                    and nextPositionX == segment.x
                    and nextPositionY == segment.y then
                        canMove = false
                        snakeAlive = false
                    end
                end
    
                -- move a cobra para anova posição ou termina o jogo (em caso de colisão)
                if canMove then
                    local newColor = snake[1].color
    
                    table.insert(snake, 1, {
                        x = nextPositionX,
                        y = nextPositionY,
                        color = snake[1].color
                    })
                    
                    -- verifica se a cobra comeu a comida
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

-- função para adicionar uma nova direção à fila de direção da cobra
function queueDirection(newDirection, oppositeDirection)
    if directionQueue[#directionQueue] ~= newDirection
    and directionQueue[#directionQueue] ~= oppositeDirection then 
        table.insert(directionQueue, newDirection)
    end
end

-- função chamada quando uma tecla do teclado é pressionada 
function love.keypressed(key)

    if key == 'return' and gameState == 'start' then
        gameState = 'playing'
    elseif key == 'return' and gameState == 'gameOver' then
        reset()
        gameState = 'playing'
    elseif key == 'right' then
        queueDirection('right', 'left')
        
    elseif key == 'left' then
        queueDirection('left', 'right')
    elseif key == 'up' then
        queueDirection('up', 'down')
    elseif key == 'down' then
        queueDirection('down', 'up')
    end
end

function love.draw()
    
    local cellSize = 20

    -- função que desenha uma célula na grade
    local function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            
            cellSize - 1,
            cellSize - 1
        )
    end

    -- função que escreve um texto na tela com uma imagem associada
    local function writeText(text, image, addHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            text, 
            0, 
            love.graphics.getHeight() / 2 + addHeight, 
            love.graphics.getWidth(), 
            "center"
        )
        love.graphics.draw(
            image, 
            (love.graphics.getWidth() - image:getWidth()) / 2, 
            (love.graphics.getHeight() - image:getHeight() - 120) / 2
        )
    end

    -- desenha a tela inicial
    if gameState == 'start' then
        writeText('Aperte ENTER para iniciar', images[1], 80)
    
    -- desenha o estado atual do jogo
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
    
    -- desenha a tela de game over
    elseif gameState == 'gameOver' then
        writeText('Aperte ENTER para reiniciar', images[2], 0)
    end
end