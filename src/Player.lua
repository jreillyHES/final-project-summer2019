--[[
    GD50
    Super Mario Bros. Remake

    -- Player Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.score = 0
    self.keyObtained = false
    self.lockBlockX = 0
    self.LockBlockY = 0
    -- initialize values
    self.goal = "Obtain the Key!"
    self.gameLevel = 1
    self.lives = 3
    self.usedScoreBonus = false
    self.message = ""
    
    -- flags for flashing the player has invincibility
    self.invincibility = false
    self.invincibilityTimer = 0

    -- timer for turning transparency on and off, flashing
    self.flashTimer = 0
    
end

function Player:update(dt)
    Entity.update(self, dt)
    -- if have not use the scoring bonus and score has reached or exceeded scoring bonus
    -- add another player life and set used scoring bonus to true
    if not self.usedScoreBonus and self.score >= SCORE_FOR_EXTRA_LIFE then
        gSounds['pickup']:play()
        self.lives = self.lives + 1
        self.usedScoreBonus = true
        self.message = "Extra Life Granted!"
    end
    -- if play has invincibility awarded
    -- player flashing controlled by flash timer when rendering
    --  set message to invincibility has ended
    if self.invincibility then
        self.flashTimer = self.flashTimer + dt
        self.invincibilityTimer = self.invincibilityTimer + dt

        if self.invincibilityTimer > INVINCIBILITYDUURATION then
            self.invincibility = false
            self.invincibilityTimer = 0
            self.flashTimer = 0
            self.message = "Invincibility Has Ended!"
        end
    end
    
end

function Player:render()
    if self.invincibility and self.flashTimer > 0.06 then
        -- flash for invincibility
        self.flashTimer = 0
        love.graphics.setColor(255, 255, 255, 64)
    end
    Entity.render(self)
    love.graphics.setColor(255, 255, 255, 255)
end

function Player:checkLeftCollisions(dt)
    -- check for left two tiles collision
    local tileTopLeft = self.map:pointToTile(self.x + 1, self.y + 1)
    local tileBottomLeft = self.map:pointToTile(self.x + 1, self.y + self.height - 1)

    -- place player outside the X bounds on one of the tiles to reset any overlap
    if (tileTopLeft and tileBottomLeft) and (tileTopLeft:collidable() or tileBottomLeft:collidable()) then
        self.x = (tileTopLeft.x - 1) * TILE_SIZE + tileTopLeft.width - 1
    else
        
        -- allow us to walk atop solid objects even if we collide with them
        self.y = self.y - 1
        local collidedObjects = self:checkObjectCollisions()
        self.y = self.y + 1

        -- reset X if new collided object
        if #collidedObjects > 0 then
            self.x = self.x + PLAYER_WALK_SPEED * dt
        end
    end
end

function Player:checkRightCollisions(dt)
    -- check for right two tiles collision
    local tileTopRight = self.map:pointToTile(self.x + self.width - 1, self.y + 1)
    local tileBottomRight = self.map:pointToTile(self.x + self.width - 1, self.y + self.height - 1)

    -- place player outside the X bounds on one of the tiles to reset any overlap
    if (tileTopRight and tileBottomRight) and (tileTopRight:collidable() or tileBottomRight:collidable()) then
        self.x = (tileTopRight.x - 1) * TILE_SIZE - self.width
    else
        
        -- allow us to walk atop solid objects even if we collide with them
        self.y = self.y - 1
        local collidedObjects = self:checkObjectCollisions()
        self.y = self.y + 1

        -- reset X if new collided object
        if #collidedObjects > 0 then
            self.x = self.x - PLAYER_WALK_SPEED * dt
        end
    end
end

function Player:checkObjectCollisions()
    local collidedObjects = {}

    for k, object in pairs(self.level.objects) do
        if object:collides(self) then
            if object.solid then
                table.insert(collidedObjects, object)
            elseif object.consumable then
                object.onConsume(self)
                table.remove(self.level.objects, k)
            end
        end
    end

    return collidedObjects
end