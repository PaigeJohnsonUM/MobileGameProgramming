-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------


local background = display.newImageRect( "background.png", 360, 570 )
background.x = display.contentCenterX
background.y = display.contentCenterY
local farground = display.newGroup()


local floorCollisionFilter = { categoryBits=1, maskBits=6 }  -- Floor collides only with 2 and 4
local redCollisionFilter = { categoryBits=2, maskBits=3 }    -- Red collides only with 1 and 2

local platform = display.newImageRect(farground, "platform.png", 300, 50 )
platform.x = display.contentCenterX
platform.y = display.contentHeight-25
local balloon = display.newImageRect(farground, "balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.8

local physics = require( "physics" )
physics.start()

physics.addBody( platform, "static",{filter=floorCollisionFilter} )
physics.addBody( balloon, "dynamic", { radius=50, bounce=0.9,friction = 0.0, filter = redCollisionFilter } )

local function pushBalloonLeft()
	balloon:applyLinearImpulse( -0.10, 0, balloon.x, balloon.y )
end
local function pushBalloonRight()
	balloon:applyLinearImpulse( 0.10,0, balloon.x, balloon.y)
end



local border1 = display.newRect(farground,0,0, 1,3400)
physics.addBody( border1, "static",{filter=floorCollisionFilter} )
local border2 = display.newRect( farground ,340,0,1,3400)
physics.addBody( border2, "static",{filter=floorCollisionFilter} )

local spawnTimer
local spawnedObjects = {}
 
-- Seed the random number generator
math.randomseed( os.time() )
local spawnParams = {
    xMin = 20,
    xMax = 300,
    yMin = 0,
    yMax = 24,
    spawnTime = 10,
    spawnOnTimer = 1,
    spawnInitial = 1
}
-- Spawn an item
local function spawnItem( bounds )
 
    -- Create an item
    local item = display.newCircle(farground, 2, 2, 20 )
 
    -- Position item randomly within set bounds
    item.x = math.random( bounds.xMin, bounds.xMax )
    item.y = math.random( bounds.yMin, bounds.yMax )
    physics.addBody(item,"dynamic",{bounce=1,friction=0.0})

    -- Add item to "spawnedObjects" table for tracking purposes
    spawnedObjects[#spawnedObjects+1] = item
    if (item.y > display.contentHeight) then
        item.removeSelf()
        item=nil
    end
end

local function spawnController( action, params )
 
    -- Cancel timer on "start" or "stop", if it exists
    if ( spawnTimer and ( action == "start" or action == "stop" ) ) then
        timer.cancel( spawnTimer )
    end
 
    -- Start spawning
    if ( action == "start" ) then
 
        -- Gather/set spawning bounds
        local spawnBounds = {}
        spawnBounds.xMin = params.xMin or 0
        spawnBounds.xMax = params.xMax or display.contentWidth
        spawnBounds.yMin = params.yMin or 0
        spawnBounds.yMax = params.yMax or display.contentHeight
 
        -- Gather/set other spawning params
        local spawnTime = params.spawnTime or 1000
        local spawnOnTimer = params.spawnOnTimer or 50
        local spawnInitial = params.spawnInitial or 0
 
        -- If "spawnInitial" is greater than 0, spawn that many item(s) instantly
        if ( spawnInitial > 0 ) then
            for n = 1,spawnInitial do
                spawnItem( spawnBounds )
            end
        end
 
        -- Start repeating timer to spawn items
        if ( spawnOnTimer > 0 ) then
            spawnTimer = timer.performWithDelay( spawnTime,
                function() spawnItem( spawnBounds ); end,
            spawnOnTimer )
        end
 
    -- Pause spawning
    elseif ( action == "pause" ) then
        timer.pause( spawnTimer )
 
    -- Resume spawning
    elseif ( action == "resume" ) then
        timer.resume( spawnTimer )
    end
end
local function myListener( event )
    spawnController ("start", spawnParams)
end
local forground = display.newGroup()
local right = display.newImageRect(forground,"Right.png",95,95)
right.x=display.contentWidth - 50
right.y=display.contentHeight - 15

local left = display.newImageRect(forground,"Left.png",95,95)
left.x=50
left.y=display.contentHeight - 15

left:addEventListener( "tap", pushBalloonLeft )
right:addEventListener("tap", pushBalloonRight )
Runtime:addEventListener( "enterFrame", myListener )