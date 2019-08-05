--[[
    GD50
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.camX = 0
    self.camY = 0
    self.backgroundX = 0
    self.width = 0
    self.gravityOn = true
    self.gravityAmount = 6
end

function PlayState:enter(params)
    
    -- grab score and width from params if it was passed
    self.score = params.score or 0    
    self.width = params.width or 100

    -- spawn a level, tile map and background
    self.level = LevelMaker.generate(self.width, 10, true)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    
    -- spawn a player for this level
    self.player = Player({
        -- make sure player starts above solid ground
        x = self:findSolidGround(), y = 0,
        width = 16, height = 20,
        texture = 'green-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level
    })

    -- spawn enemies for this level
    self:spawnEnemies()
    
    -- set the player score
    self.player.score = self.score
    
    -- set player to falling into this level
    self.player:changeState('falling')
end

function PlayState:update(dt)
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.player:update(dt)
    self.level:update(dt)
    self:updateCamera()

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
    
    -- render score
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(tostring(self.player.score), 5, 5)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(tostring(self.player.score), 4, 4)

    -- render the current game goal
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf(self.player.goal, 40, 4, 200, ("right"))
    -- display level width
    love.graphics.printf("Level Width: "..tostring(self.tileMap.width), 40, 14,200,("right"))
    -- used to capture message only during program debugging
    love.graphics.printf(debugMessage, 40, 24,200,("right"))
end    

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then
                        
                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end


function PlayState:findSolidGround()
    -- ground x value for the first column with ground on this level
    -- and make sure there are objects at or above ground level
    local groundX = 0
    -- flag for whether there's ground on this column of the level
    local groundFound = false
    for x = 1, self.tileMap.width do
        -- iterate through the columns
        for y = 1, self.tileMap.height do
            if LevelMaker.findObject(((x - 1) * TILE_SIZE) ,((y - 1) * TILE_SIZE),self.level.objects) then
                -- convert x and y to tiles so we check check if
                -- object found at this location
                -- if so, need to move on to another column
                break
            end              
            if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
               -- found ground so get x value and exit the inner loop
               groundFound = true
               groundX = (x - 1) * TILE_SIZE
               break
            end
        end
        if groundFound == true then
           -- exit outer loop if found ground
           break
        end    
    end
    
    return groundX
end
