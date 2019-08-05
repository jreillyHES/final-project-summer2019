--[[
--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height,generateKey)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    
    -- determine random key selection
    -- assign same random to lock block
    local keySelection = math.random(#KEYS)

    -- determine random goal post selection
    local flagPoleSelection = math.random(6)
    
    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        -- but don't generate for last column
        -- because we do not want flag pole to 
        -- be suspended in mid-air
        if math.random(7) == 1 and x < width then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            -- pillar ok on last column because flag pole 
            -- will sit on top
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                -- but don't generate for last column
                -- because we do not want flag pole to 
                -- be sitting on top of an object
                if math.random(8) == 1 and x < width then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            -- but don't generate for last column
            -- because we do not want flag pole to 
            -- be sitting on top of an object
            elseif math.random(8) == 1 and x < width then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            -- but don't generate for last column
            -- because we do not want flag pole to 
            -- be sitting on top of an object
            if math.random(10) == 1 and x < width then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end

        end
    end
    

    local map = TileMap(width, height)
    map.tiles = tiles

    -- only generate key if we are in Play State
    if generateKey then
        -- generate a key in a random location 
        -- that is at least 10 tiles into this level
        -- and is not currently occupied by an object or a pillar
        local emptyX, emptyY = LevelMaker.findEmptySpace(width, height,tiles,objects)
        table.insert(objects,
            GameObject {
                texture = 'keys-and-locks',
                x = emptyX,
                y = emptyY,
                width = 16,
                height = 16,
                -- use random key selection
                frame = KEYS[keySelection],
                collidable = true,
                consumable = true,
                solid = false,
                -- key has its own function to 
                -- set goal to unlock the lock block
                -- and draw the lock block to match the same key selection
                -- that is at least 10 tiles into this level
                -- and is not currently occupied by an object or a pillar
                onConsume = function(player, object)
                    gSounds['pickup']:play()
                    player.goal = "Unlock the Lock Block!"
                    player.newWidth = width
                end
            }
        )    
        -- generate lock block
        emptyX, emptyY = LevelMaker.findEmptySpace(width, height,tiles,objects)                    
        table.insert(objects,
            GameObject {
                texture = 'keys-and-locks',
                x = emptyX,
                y = emptyY,
                width = 16,
                height = 16,
                frame = LOCK_BLOCKS[keySelection],
                collidable = true,
                consumable = true,
                -- lock block has its own function to 
                -- set goal to capture the flag
                -- and draw the flag and flagpole
                -- since randonly generated, lock block can be before or after
                -- the location of the key
                onConsume = function(player, object)
                    gSounds['pickup']:play()
                    player.goal = "Capture the Flag!"
                    -- generate flag pole and flag
                    -- making sure on top of topper
                    local flagY = LevelMaker.findTopper(width, height,tiles)
                    for y1 = 0, 2 do
                        table.insert(objects,
                            GameObject {
                                texture = 'flags',
                                x = (width - 1 ) * TILE_SIZE,
                                y = flagY - (2 - y1) * TILE_SIZE,
                                width = 16,
                                height = 16,
                                frame = FLAGPOLES[flagPoleSelection + (y1 * 6)],
                                collidable = true,
                                consumable = true,
                                -- lock block has its own function to 
                                -- set goal to capture the flag
                                -- and draw the flag and flagpole
                                onConsume = function(player, object)
                                    gSounds['powerup-reveal']:play()
                                    gStateMachine:change('play', {
                                        -- when player touches flag post,
                                        -- maintain player score  
                                        -- and expand width of level by 10%    
                                        score = player.score,
                                        width = player.newWidth + math.floor(player.newWidth * .1)
                                    })    
                                end             
                            }
                        )
                    end
                    table.insert(objects,
                        GameObject {
                            texture = 'flags',
                            -- adjust flag position properly on flag pole
                            x = (width - 1 ) * TILE_SIZE + 6,
                            y = flagY - 1 * TILE_SIZE,
                            width = 16,
                            height = 16,
                            orientation = 3.17,
                            frame = FLAGS[math.random(#FLAGS)],
                            collidable = true,
                            consumable = true,
                            -- lock block has its own function to 
                            -- set goal to capture the flag
                            -- and draw the flag and flagpole
                            onConsume = function(player, object)
                                gSounds['powerup-reveal']:play()
                                gStateMachine:change('play', {
                                    -- when player touches flag post,
                                    -- maintain player score  
                                    -- and expand width of level by 10%    
                                    score = player.score,
                                    width = player.newWidth + math.floor(player.newWidth * .1)
                                })    
                            end             
                        }
                    )
                end
            }
        )    
            
        
    end
    

    return GameLevel(entities, objects, map)

end

function LevelMaker.findObject (x,y,objects)
    -- find an object on the map
    -- default to object not found
    local objectFound = false
    for i = 1, table.getn(objects) do
        if objects[i].x == x and objects[i].y == y then
            -- object found at this location
            objectFound = true
        end        
    end     
    return objectFound     
end    
    
function LevelMaker.findEmptySpace(width, height,tiles,objects)
    -- look for first column with ground
    local x1 = 0
    local y1 = 0
    local objectCleared = false
    -- repeat until we find an empty space free of objects
    repeat
        -- generate a random column between the 5th column and 5 before the last column
        x1 = (math.random(5,width-5)) 
        -- default row to ground level in case of gap
        y1 = 6  
        for y = 1, height do
           if tiles[y][x1].topper then
              -- found ground so place y1 one above ground
              y1 = y - 1
          end
       end
       -- randomly place 1, 2, or 3 spaces above ground 
       -- and convert x1 and y1 to tiles 
       y1 = (y1 - math.random(3)) * TILE_SIZE
       x1 = (x1 - 1)  * TILE_SIZE
       if LevelMaker.findObject(x1,y1,objects) == false then
          -- no object found at this location
          -- so we have cleared object check    
          objectCleared = true
       end    
   until(objectCleared == true)
   return (x1), (y1)
end


function LevelMaker.findTopper(width, height,tiles)
    -- find the ground topper on the same column
    -- so we can place flagpole
    -- default row to ground level in case of gap
    local flagY = 6  
    for y = 1, height do
        if tiles[y][width].topper then
           -- found ground so place y1 one above ground
           flagY = y - 1
       end
    end
    flagY = (flagY - 1) * TILE_SIZE
    -- and convert y1 to tiles 
    return flagY
end
