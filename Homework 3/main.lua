local lives = 3
local score = 0
local died = false
 
local RabbitsTable = {} -- this is an array
 
local knight
local gameLoopTimer
local livesText
local scoreText
local currentDelay = 500
local timeToChange = 5

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) Rabbit 1
        x = 128,
        y = 0,
        width = 665-128,
        height = 428 
        },
        {   -- 2) Rabbit 2
            x = 0,
            y = 428,
            width = 503,
            height = 1056-428
        },
        {   -- 3) Rabbit 3
            x = 585,
            y = 519,
            width = 1156-585,
            height = 1056-519
        },
        {   -- 4) Ya boi
            x = 1228,
            y = 55,
            width = 1892-1228,
            height = 1009-55
        },
        {   -- 5) Holy Hand Grenades
            x = 773,
            y = 0,
            width = 1219-773,
            height = 519
        },
    },
}

local objectSheet = graphics.newImageSheet( "HW2Sprites.png", sheetOptions )

-- Load the background
local backGroup = display.newGroup()

local background = display.newImageRect("Background.png", 800, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY

backGroup:insert(background)

local mainGroup = display.newGroup()
Artie = display.newImageRect( mainGroup, objectSheet, 4, 130, 200 )
Artie.x = display.contentCenterX
Artie.y = display.contentHeight
physics.addBody( Artie, { radius=30, isSensor=true } )
Artie.myName = "Artie"
mainGroup:insert(Artie)

local uiGroup = display.newGroup()
livesText = display.newText( "Lives: " .. lives, display.contentCenterX, 0, native.systemFont, 18 )
scoreText = display.newText( "Score: " .. score, display.contentCenterX,20, native.systemFont, 18 )
uiGroup:insert(livesText)
uiGroup:insert(scoreText)

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- this function updates the stats of the game
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

-- this function creates variety of Rabbits and adds them to the table
local function createRabbit()
    local mainGroup = display.newGroup()
    local newRabbit = display.newImageRect( objectSheet, 1, 102, 85 )
    
    -- add the Rabbit to the table
    table.insert( RabbitsTable, newRabbit )
    physics.addBody( newRabbit, "dynamic", { radius=40, bounce=0.8 } )
    newRabbit.myName = "Rabbit" -- this is a tag name so we can use this in collision
    local whereFrom = math.random(1, 3 ) -- how do we know what the range is?
   -- whereFrom = 1
    if ( whereFrom == 1 ) then
        -- From the left
        newRabbit.x = -60
        newRabbit.y = math.random( 500 )
        newRabbit:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        newRabbit.x = math.random( display.contentWidth )
        newRabbit.y = -60
        newRabbit:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newRabbit.x = display.contentWidth + 60
        newRabbit.y = math.random( 500 )
        newRabbit:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end
    newRabbit:applyTorque( math.random( -6,6 ) )
    mainGroup:insert(newRabbit)
 
end

-- this function launchs the grenade after creating it
-- it uses the transition.to to move the grenade up to a new location over time
local function launchgrenade()
    local mainGroup = display.newGroup()
    local newgrenade = display.newImageRect(objectSheet, 5, 14, 40 )
    physics.addBody( newgrenade, "dynamic", { isSensor=true } )
    newgrenade.isBullet = true
    newgrenade.myName = "grenade"
    newgrenade.x = Artie.x
    newgrenade.y = Artie.y
    newgrenade:toBack()
    transition.to( newgrenade, { y=-40, time=500,
        onComplete = function() display.remove( newgrenade ) end
    } )
    mainGroup:insert(newgrenade)
end

Artie:addEventListener( "tap", launchgrenade )

-- this function moves Artie by figuring out the offset of the mouse x,y from Artie x and y
-- this determines the new location of the mouse and adjusts Artie taking into account the
-- the offset
local function dragArtie( event )
 
    local Artie = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the Artie
        display.currentStage:setFocus( Artie )
        -- Store initial offset position
        Artie.touchOffsetX = event.x - Artie.x
        Artie.touchOffsetY = event.y - Artie.y

    elseif ( "moved" == phase ) then
        
        

        -- Moves Artie to the new touch position
        Artie.x = event.x - Artie.touchOffsetX
        Artie.y = event.y - Artie.touchOffsetY
        
        -- Store initial offset position
        Artie.touchOffsetX = event.x - Artie.x
        Artie.touchOffsetY = event.y - Artie.y
    
        --Artie.x = event.x - Artie.touchOffsetX
        --Artie.y = event.y - Artie.touchOffsetY
        

    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on Artie
        display.currentStage:setFocus( nil )
    end

    return true  -- Prevents touch propagation to underlying objects


end

Artie:addEventListener( "touch", dragArtie )

-- this is the loop that creates new Rabbits over and over
local function gameLoop()

    -- this section is where we can increase the speed of the Rabbit creation
    if(timeToChange >= 5) then
        currentDelay = currentDelay - 10
       -- maybe it was just that we needed to cancel and restart
       -- in a new location
        timer.cancel(gameLoopTimer); -- stop the timer here
        -- restart the timer with the new value here
        gameLoopTimer = timer.performWithDelay( currentDelay, gameLoop, 0)
        timeToChange = 0
       
    end

 -- Create new Rabbit
 createRabbit()

 -- Remove Rabbits which have drifted off screen
 -- for(var i = 0; i < 5; i++)
 -- for(var i = RabbitsTable.length; i > 0; i--)
 for i = #RabbitsTable, 1, -1 do
    local thisRabbit = RabbitsTable[i]
 
    if ( thisRabbit.x < -100 or
         thisRabbit.x > display.contentWidth + 100 or
         thisRabbit.y < -100 or
         thisRabbit.y > display.contentHeight + 100 )
    then
        display.remove( thisRabbit )
        table.remove( RabbitsTable, i )
    end
 end
 timeToChange = timeToChange + 1
 

end

--local function startGameLoop()

    --gameLoopTimer = timer.performWithDelay( currentDelay, gameLoop, 0 )

--end

--print(currentDelay)
gameLoopTimer = timer.performWithDelay( currentDelay, gameLoop, 0)

--otherTimer = timer.performWithDelay( 1000, startGameLoop, 0 )

-- this function brings the Artie back using the transition.to and alpha value
local function restoreArtie()
 
    Artie.isBodyActive = false
    Artie.x = display.contentCenterX
    Artie.y = display.contentHeight 
 
    -- Fade in the Artie
    transition.to( Artie, { alpha=1, time=4000,
        onComplete = function()
            Artie.isBodyActive = true
            died = false
        end
    } )
end

-- this is the collision function that checks collision based on their names
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2
        if ( ( obj1.myName == "grenade" and obj2.myName == "Rabbit" ) or
             ( obj1.myName == "Rabbit" and obj2.myName == "grenade" ) )
        then
            -- Remove both the grenade and Rabbit
            display.remove( obj1 )
            display.remove( obj2 )
            for i = #RabbitsTable, 1, -1 do
                if ( RabbitsTable[i] == obj1 or RabbitsTable[i] == obj2 ) then
                    table.remove( RabbitsTable, i )
                    break
                end
            end
             -- Increase score
             score = score + 100
             scoreText.text = "Score: " .. score
            elseif ( ( obj1.myName == "Artie" and obj2.myName == "Rabbit" ) or
            ( obj1.myName == "Rabbit" and obj2.myName == "Artie" ) )
            then
                if ( died == false ) then
                    died = true
                        -- Update lives
                    lives = lives - 1
                    livesText.text = "Lives: " .. lives

                    if ( lives == 0 ) then
                        display.remove( Artie )
                    else
                        Artie.alpha = 0
                        timer.performWithDelay( 1000, restoreArtie )
                    end
                end
        end
    end
end
Runtime:addEventListener( "collision", onCollision )
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here