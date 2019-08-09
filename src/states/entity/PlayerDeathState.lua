--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerDeathState = Class{__includes = BaseState}

function PlayerDeathState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {1},
        interval = 1
    }

end

function PlayerDeathState:update(dt)
    -- play death music
    gSounds['death']:play()
    
        
    if self.player.lives == 1 then
        -- if last life,
        -- set message to game over
        self.player.message = "Game Over!"
    else
        -- if more than 1 life left
        -- subtract life from player
        -- and set message to player died
        self.player.lives = self.player.lives - 1
        self.player.message = "Player Died!"
    end
end