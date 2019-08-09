"# final-project-summer2019" 

Super Mario Bros.

1. Add actual levels to the game. Display the current level in the upper right corner and display a message when the level is completed.  Give a scoring bonus times the level number when a level is cleared. 


2. When loading a level, have the flagpole (but not the flag!) generate on the last block which should be solid ground so the flagpole does not float in mid-air. Also, randomly generate the key and lock block when loading the level. The player must first obtain the key (onConsume) before unlocking the lock block (onConsume). When the lock block is opened, the flag will appear at the top of the flagpole. The player completes the level by capturing the flag (onConsume).


3. Add three lives to the game, displaying the lives left in the upper left corner. If a player dies with lives left, drop them back into the level at the same location but making sure they are always above solid ground. Move the player forward in the level if necessary.


4. Add a random chance to generate a heart for an extra life when generating a gem only if the player has less than 3 lives left. Also, award an extra life if the player achieves a certain score. This award can be received even if the player already has 3 lives. In this case only, a player can have a maximum of 4 lives. 


5. Add a random chance to generate a star for invincibility when generating a gem. Invincibility should only last for a set period a time and does not extend to the next game level. A player that has invincibility cannot be killed by enemies or fall below ground level in gaps. Enemies die instead on collision when player has invincibility.


Testing Notes
-------------

-- Scoring bonus = 100 * game level
-- Lock block is solid and cannot be consumed until flag is consumed
-- Flag pole does not have a flag until lock bock is consume
-- Consuming the flag complete the game level
-- 1 in 4 chance to spawn an object
-- if we spawn an object, 1 in 3 chance either heart or star and 2 in 3 change gem
-- for testing purposes, game levels 1, 2 and 3 have a 100% chance of spawning object and 50% chance of spawning either heart or star
-- heart only allowed if less than 3 lives left and heart object does not already exist on level
-- star only allowed if star object does not already exist on leveland player is not already invincible
-- Extra Life at score of 1,000 points
-- Invincibility lasts 15 seconds


Programming Notes
-----------------

1. Add actual levels to the game.

In StartState.lau
 --  start new game with player score at 0
 -- level width at 50, game level at 1
 -- 3 player lives and not used score bonus        

In constants.lau
-- score bonus for completing a level
-- multipled by the level completed
SCORING_BONUS_LEVEL = 100

In PlayState.Lau
-- display game level message when starting a game level
-- but do not pause the game

-- display message for completing level
-- apply scoring bonus for completing level
-- pause the game for the message

-- when player captures flag,
-- maintain player score
-- expand width of level by 10%    
-- advance game level 
-- and maintain lives and used scoring bonus indicator    


2. When loading a level, have the flagpole (but not the flag!) generate on the last block which should be solid ground so the flagpole does not float in mid-air.

In Player.lau
-- initialize values
self.goal = "Obtain the Key!"

In LevelMaker.lau
-- generate a key in a random location 
-- that is at least 10 tiles into this level
-- and is not currently occupied by an object or a pillar

-- generate a lock block in a random location 
-- that is at least 10 tiles into this level
-- and is not currently occupied by an object or a pillar
-- since randonly generated, lock block can be before or after
-- the location of the key
-- initialize as solid and not consumable
-- obtain key will make lock block consumable

-- generate flag pole
-- making sure on top of topper
-- do nothing on collision 
-- must capture the flag, not touch the flag pole    


-- key has its own consume function to 
-- set lock block to consumable
-- set goal to unlock the lock block

-- lock block has its own consume function to 
-- set goal to capture the flag
-- and draw the flag

-- flag has its own consume function to 
-- set message to level completed


In PlayState.Lau
-- display message for completing level
-- apply scoring bonus for completing level
-- pause the game for the message

-- when player captures flag,
-- maintain player score
-- expand width of level by 10%    
-- advance game level 
-- and maintain lives and used scoring bonus indicator    


3. Add three lives to the game, displaying the lives left in the upper left corner.

In Player.lau
-- initialize values
self.lives = 3

In PlayerDeathState.lau
-- if last life,
-- set message to game over

-- if more than 1 life left
-- subtract life from player
-- and set message to player died

In PlayState.Lau
-- render hearts for player lives
-- change scale for better rendering

-- display message for player has died
-- pause the game for the message
-- drop player back into the level at the same location 
-- but make sure player is always above solid ground 
-- Move the player forward in the level if necessary

-- display message for game over
-- pause the game for the message
-- once that's complete, we're ready to return to start


4. Add a random chance to generate a heart for an extra life when generating a gem only if the player has less than 3 lives left.

In constants.lau
-- Score for extra life award
SCORE_FOR_EXTRA_LIFE = 1000

HEARTS = {
    -- 5 is heart for player life, 6 is star for invincibility
    5, 6
}

In Player.lau
-- initialize values
self.usedScoreBonus = false

-- if have not use the scoring bonus and score has reached or exceeded scoring bonus
-- add another player life and set used scoring bonus to true

In LevelMaker.lau
-- spawn a gem or special object if we haven't already hit the block
-- chance to spawn gem or special object, not guaranteed
-- spawn either gem or special object (if allowed)
-- 1 in 4 chance to spawn an object
-- if we spawn an object, 1 in 3 chance either heart or star and 2 in 3 change gem
-- equal chance to spawn either heart or star
-- for testing purposes, game levels 1, 2 and 3 have a 100% chance of spawning object and 50% chance of spawning either heart or star
-- heart only allowed if less than 3 lives left
-- make sure a heart object does not already exist on level
-- not allowed to spawn more than 1 heart
-- heart has its own consume function to add to the player's score

In PlayState.Lau
-- display message for extra life granted
-- but do not pause game


5. Add a random chance to generate a star for invincibility when generating a gem.

In constants.lau
-- invincibility duration in seconds
INVINCIBILITYDUURATION = 15

HEARTS = {
    -- 5 is full heart for player life, 6 is star for invincibility
    5, 6
}

In LevelMaker.lau
-- spawn a gem or special object if we haven't already hit the block
-- chance to spawn gem or special object, not guaranteed
-- 1 in 4 chance to spawn an object
-- if we spawn an object, 1 in 3 chance either heart or star and 2 in 3 change gem
-- equal chance to spawn either heart or star
-- for testing purposes, game levels 1, 2 and 3 have a 100% chance of spawning object and 50% chance of spawning either heart or star
-- make sure a star object does not already exist on level
-- and player is not already invincible
-- not allowed to spawn more than 1 star
-- star has its own consume function to temporarily add invincibility to player

In Player.lau
-- flags for flashing the player has invincibility
self.invincibility = false
self.invincibilityTimer = 0

-- timer for turning transparency on and off, flashing
self.flashTimer = 0
    
-- if player has invincibility awarded
-- player flashing controlled by flash timer when rendering
--  set message to invincibility has ended

In PlayState.Lau
-- display message for invincibility awarded
-- but do not pause game

-- display message for invincibility has ended
-- but do not pause game

In PlayerIdleState.lau, PlayerJumpState.lau and PlayerWalkingState.lau
-- if player has invincibility
-- entity dies instead on collision

In PlayerFallingState.lau
-- if player has invincibility and has fallen below ground level
-- do not allow player to fall to their death in gap
-- stop gravity and move player back to ground level
-- if facing right, move right one tile
-- if facing left, move left one tile

