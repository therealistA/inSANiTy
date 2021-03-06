local composer = require("composer")
local widget = require( "widget" )
local physics = require("physics")
local Obstacle = require("obstacle")

local scene = composer.newScene()

local roboBlock
local floor
local backgroundMusic

local level = {}

local levelMovementSpeed = 400
local levelMovementEnabled = true

local firstJumpCollision = false
local jumpEnabled = true

-- The width of objects in the level
local objectWidth = 30 

-- The width of the stoke used on objects in the lvel
local objectStrokeWidth = 3

-- The combined width of the an object and its stoke on both sides (i.e. the width of a tile)
local tileWidth = objectWidth + (2 * objectStrokeWidth)

-- The number of tiles down from the top of the screen the floor is located at
local floorY = 6

local blackColorTable = {0, 0, 0}
local whiteColorTable = {1, 1, 1}
local transparentColorTable = {0, 0, 0, 0}
local semiTransparentColorTable = {0, 0, 0, 0.75}

local winText
local loseText
local level3

local retryButton
local menuSceneButton

-- --------------------------------
-- This is to paint roboBlock -- AA
-- -------------------------------
local roboBlockFace = {
    type = "image",
    filename = "roboBlockFace.png"
} 
local roboBlockScared = {
    type = "image",
    filename = "roboBlockScared.png"
}
-- --------------------------------
-- Sound Effects -- AA
-- --------------------------------
local hitObjectSound = audio.loadSound("hitObject.wav")
local jumpSound = audio.loadSound("jump.wav")
local loseSound = audio.loadSound("evilLaugh.wav")

-- --------------------------------
-- This is for the monster - AA
-- --------------------------------
local monsterGroup
local roboBlocksGroup
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function retryScene()
    local sceneTransitionsOptions = 
    {
        effect = "crossFade",
        time = 500,
    }

    composer.removeScene("game3")
    composer.gotoScene("game3", sceneTransitionsOptions)
end

local function gotoMenuScene()
    local sceneTransitionsOptions = 
    {
        effect = "crossFade",
        time = 500,
    }

    composer.removeScene("game3")
    composer.gotoScene("titleScene", sceneTransitionsOptions)
end

-- Function to handle button events
local function handleButtonEvent(event)
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released" )
    end
end 

-- The collision handler, this method runs when a collision occurs with a physics body
local function onCollisionOccurred(event)
    print(event.target.myName..": Collision with "..event.other.myName)
    
    -- Collisions with the floor or transparent square do not result in a loss, any other collision does
    -- Collisions with the floor or transparent square enable jumping
    if event.other.myName ~= nil and (event.other.myName == "Floor" or event.other.myName == "TransparentSquare") then
        -- putting in a dumb boolean to keep the collision while the block is rising from marking jumpEnabled as true
        if firstJumpCollision == true then
            jumpEnabled = true
        else
            firstJumpCollision = true      
        end
    else
        if event.other.myName == "EndFlag" then
            menuSceneButton.isVisible = true

            win.isVisible = true
            elder.isVisible = true
            crazy.isVisible = true
            woman.isVisible = true

           
        else
            -- if collising with the bottom, make the bloack a sensor so it falls through and doesn't collide forever            
            if event.other.myName ~= nil and event.other.myName == "Bottom" then
                roboBlock.isSensor = true
            end
            -- ---------------------------------------------
            -- This is to show roboBlock's scared Face -- AA
            -- ---------------------------------------------
            roboBlockFace.isVisible = false
            roboBlock.fill = roboBlockScared

            audio.play(hitObjectSound)
            audio.play(loseSound)

            lostMessage.isVisible = true
            monster1.isVisible = true
            monster2.isVisible = true
            monster3.isVisible = true
            monster4.isVisible = true

            retryButton.isVisible = true
            menuSceneButton.isVisible = true
        end
        
        levelMovementEnabled = false 
        firstJumpCollision = false
        jumpEnabled = false 
    end

    print("Roboblock name: "..roboBlock.myName)
    local vx, vy = roboBlock:getLinearVelocity()

    -- Set linear velocity to 0 if the block is sliding
    if vx ~= 0 then
        --print("Setting linear velocity to 0")
        roboBlock:setLinearVelocity(0, vy)
    end
end

local function onCollision(event)
    Runtime:dispatchEvent({name="onCollisionOccurred", target = event.target, other = event.other})
end

-- Moves roboBlock on screen touch
local function screenTouched(event)
    if event.phase == "began" and jumpEnabled == true then
        roboBlock:applyLinearImpulse(0, -0.22, roboBlock.x, roboBlock.y)
        audio.play(jumpSound)     
        firstJumpCollision = false
        jumpEnabled = false
    end
end

-- This function is called recursively on each item in the level to move them on the screen
local function moveItem(item)
    if levelMovementEnabled == true then
        transition.moveBy(item, 
        {
            time = 1000, 
            x = levelMovementSpeed * -1,
            onComplete = 
                function()
                    moveItem(item)
                end
        })
    end
end

-- Iterates through each item in the level and call moveITem to move the level
local function moveLevel()
    for _, item in pairs(level) do
        moveItem(item)        
    end
end

-- This function is used to build the level
local function buildLevel()
    local Obst = Obstacle:new(
    {
        blackColorTable = blackColorTable,
        whiteColorTable = whiteColorTable,
        transparentColorTable = transparentColorTable,
        semiTransparentColorTable = semiTransparentColorTable,
        objectWidth = objectWidth,
        objectStrokeWidth = objectStrokeWidth,
        tileWidth = tileWidth
    })

    local floorLevelObstacleHeight = floorY - 1

    level = Obst:addBottom(level)

    level = Obst:spawn(level, "floor", -2, 55, floorY)
    level = Obst:spawn(level, "square", 13, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "square", 13, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 13, nil, floorLevelObstacleHeight - 4)
    level = Obst:spawn(level, "square", 13, nil, floorLevelObstacleHeight - 5)
    level = Obst:spawn(level, "square", 14, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 15, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 16, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 17, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 18, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 19, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 20, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "triangle", 14, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 15, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 16, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 17, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 18, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 19, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 20, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 21, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 22, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 23, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 24, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 25, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 26, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 27, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 28, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 29, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 30, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "square", 26, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 27, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 28, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 29, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 30, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 31, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 32, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 33, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 34, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 35, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 36, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 37, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 38, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 39, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "square", 36, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 37, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 43, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 44, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 46, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 47, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 53, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 54, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "triangle", 40, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 41, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 42, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 43, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 44, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 45, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 46, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 47, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 48, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 49, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "square", 61, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 68, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 75, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 82, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "floor", 87, 130, floorY)
    level = Obst:spawn(level, "square", 95, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 96, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 97, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 98, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 99, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 100, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 101, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 102, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 103, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 104, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 105, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "triangle", 95, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 96, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 97, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 98, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 99, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 100, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 101, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 102, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 103, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 104, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 105, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 110, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 111, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 112, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 113, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 114, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 115, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 116, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 117, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 118, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 119, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 120, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "triangle", 110, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 111, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 112, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 113, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 114, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 115, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 116, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 117, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 118, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 119, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 120, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "floor", 132, 133, floorY)
    level = Obst:spawn(level, "floor", 140, 141, floorY)
    level = Obst:spawn(level, "floor", 148, 149, floorY)
    level = Obst:spawn(level, "floor", 156, 350, floorY)
    level = Obst:spawn(level, "triangle", 162, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 163, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 164, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "triangle", 169, nil, floorLevelObstacleHeight )
    level = Obst:spawn(level, "square", 170, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 170, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "square", 171, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 172, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 175, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 176, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 177, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 178, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 179, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 180, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "triangle", 181, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "square", 181, nil, floorLevelObstacleHeight - 5)
    level = Obst:spawn(level, "square", 181, nil, floorLevelObstacleHeight - 4)
    level = Obst:spawn(level, "square", 183, nil, floorLevelObstacleHeight - 4)
    level = Obst:spawn(level, "square", 185, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 187, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 189, nil, floorLevelObstacleHeight - 1)

    level = Obst:spawn(level, "triangle", 200, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 201, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 202, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 203, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 204, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 205, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 206, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 207, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 208, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 209, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 210, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 211, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 212, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 213, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 214, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 215, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 216, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 217, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 218, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 219, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 220, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 221, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 222, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 223, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 224, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 225, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 226, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 227, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 228, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 229, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 230, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 231, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 232, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 233, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "square", 200, nil, floorLevelObstacleHeight - 1)
    level = Obst:spawn(level, "square", 206, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 212, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 219, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 226, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 233, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 240, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 242, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 243, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 244, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 245, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 251, nil, floorLevelObstacleHeight - 3)
    level = Obst:spawn(level, "square", 252, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 253, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "square", 254, nil, floorLevelObstacleHeight - 2)
    level = Obst:spawn(level, "triangle", 255, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 256, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 257, nil, floorLevelObstacleHeight)
    level = Obst:spawn(level, "triangle", 258, nil, floorLevelObstacleHeight)







    level = Obst:spawn(level, "endFlag", 260, nil, floorLevelObstacleHeight)

    



    --level = Obst:spawn(level, "endFlag", 50, nil, floorLevelObstacleHeight)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
function scene:create( event ) 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
end 
 
function scene:show( event ) 
    local sceneGroup = self.view
    local phase = event.phase
 
    if phase == "will" then
        physics.start()
        --physics.setDrawMode("hybrid")
        physics.setGravity(0, 9.8 * 5)
    
        local background = display.newImageRect(sceneGroup, "scene3.png", 575, 350 )
        background.x = display.contentCenterX 
        background.y = display.contentCenterY
        
        backgroundMusic = audio.loadSound("level3Music.mp3")
    
        buildLevel() 
    
        retryButton = widget.newButton(
        {
            label = "retryButton",
            onEvent = handleButtonEvent,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = 70,
            height = 25,
            cornerRadius = 2,
            fillColor = { default = {0 ,1, 0.23}, over={0.8,1,0.8} }, 
            strokeColor = { default= {1,0.2,0.6}, over={0,0,0} },
            strokeWidth = 5
        })

        retryButton.x = display.contentCenterX + 150
        retryButton.y = display.contentCenterY - 130
        retryButton:setLabel("RETRY")
        retryButton:addEventListener("tap", retryScene) 
        retryButton.isVisible = false

        menuSceneButton = widget.newButton(
        {
            label = "menuSceneButton",
            onEvent = handleButtonEvent,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = 70,
            height = 25,
            cornerRadius = 2,
            fillColor = { default = {0 ,1, 0.23}, over={0.8,1,0.8} }, 
            strokeColor = { default= {1,0.2,0.6}, over={0,0,0} },
            strokeWidth = 5
        })

        menuSceneButton.x = display.contentCenterX + 230 
        menuSceneButton.y = display.contentCenterY - 130
        menuSceneButton:setLabel("MENU")
        menuSceneButton:addEventListener("tap", gotoMenuScene) 
        menuSceneButton.isVisible = false
    
        win = display.newImageRect(sceneGroup, "won.png", 550,100)
        win.x = display.contentCenterX 
        win.y = display.contentCenterY - 70
        win.isVisible = false 

        lostMessage = display.newImageRect(sceneGroup, "lost.png", 550,100)
        lostMessage.x = display.contentCenterX 
        lostMessage.y = display.contentCenterY - 70
        lostMessage.isVisible = false 

        monsterGroup = display.newGroup()

        monster1 = display.newImageRect(sceneGroup, "monster.png", 50, 50)
        monster1.x = display.contentCenterX - 200
        monster1.y = display.contentCenterY - 50
        monster1.isVisible = false
        monsterGroup:insert(monster1)

        monster2 = display.newImageRect(sceneGroup, "monster.png", 65, 65)
        monster2.x = display.contentCenterX + 150
        monster2.y = display.contentCenterY - 40
        monster2.xScale = -1
        monster2.isVisible = false 
        monsterGroup:insert(monster2)

        monster3 = display.newImageRect(sceneGroup, "monster.png", 80, 80)
        monster3.x = display.contentCenterX - 100
        monster3.y = display.contentCenterY - 20
        monster3.isVisible = false 
        monsterGroup:insert(monster3)

        monster4 = display.newImageRect(sceneGroup, "monster.png", 150, 150)
        monster4.x = display.contentCenterX + 75
        monster4.y = display.contentCenterY 
        monster4.xScale = -1
        monster4.isVisible = false 
        monsterGroup:insert(monster4)

        level3 = display.newImageRect(sceneGroup, "level3.png", 100, 100)
        level3.x = display.contentCenterX - 230 
        level3.y = display.contentCenterY + 130
        level3.isVisible = true

        roboBlocksGroup = display.newGroup()

        woman = display.newImageRect(sceneGroup, "womanBlock.png", 50, 50)
        woman.x = display.contentCenterX - 200
        woman.y = display.contentCenterY - 50
        woman.isVisible = false
        roboBlocksGroup:insert(woman)

        crazy = display.newImageRect(sceneGroup, "crazyBlock.png", 65, 65)
        crazy.x = display.contentCenterX + 150
        crazy.y = display.contentCenterY - 40
        crazy.isVisible = false 
        roboBlocksGroup:insert(crazy)


        elder = display.newImageRect(sceneGroup, "elder.png", 80, 80)
        elder.x = display.contentCenterX - 100
        elder.y = display.contentCenterY - 20 
        elder.isVisible = false
        roboBlocksGroup:insert(elder)


        -- Code here runs when the scene is still off screen (but is about to come on screen) 
        roboBlock = display.newRect(0, (floorY - 1) * tileWidth, objectWidth, objectWidth)
        roboBlock.strokeWidth = objectStrokeWidth
        roboBlock:setStrokeColor(unpack(blackColorTable)) 
       
        -- -----------------------
        -- roboBlock's face -- AA
        -- -----------------------
        roboBlock.fill = roboBlockScared 
        roboBlockScared.isVisible = false
        roboBlock.fill = roboBlockFace  

        roboBlock.myName = "RoboBlock"
        roboBlock:addEventListener("collision", onCollision)   
        physics.addBody(roboBlock, "dynamic", {bounce = 0, friction = 0})
        roboBlock.angularDamping = 100
        roboBlock.isSleepingAllowed = false
    
        sceneGroup:insert(background)
        sceneGroup:insert(retryButton)
        sceneGroup:insert(menuSceneButton)
        sceneGroup:insert(win)
        sceneGroup:insert(lostMessage)
        sceneGroup:insert(monsterGroup)
        sceneGroup:insert(roboBlock)
        sceneGroup:insert(roboBlocksGroup)
        sceneGroup:insert(level3)

    elseif phase == "did" then
        -- Code here runs when the scene is entirely on screen 
        audio.setVolume(1, {channel = 2})
        local backgroundMusicChannel = audio.play(backgroundMusic, {channel = 2, loops = -1, fadein = 5000})

        Runtime:addEventListener("touch", screenTouched)
        Runtime:addEventListener("onCollisionOccurred", onCollisionOccurred)

        moveLevel()
    end
end 
 
function scene:hide( event ) 
    local sceneGroup = self.view
    local phase = event.phase
 
    if phase == "will" then
        -- Code here runs when the scene is on screen (but is about to go off screen) 
    elseif phase == "did" then
        -- Code here runs immediately after the scene goes entirely off screen 
    end
end 
 
function scene:destroy( event ) 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view   

    Runtime:removeEventListener("touch", screenTouched) 
    Runtime:removeEventListener("onCollisionOccurred", onCollisionOccurred)

    physics.stop()        

    for _, item in pairs(level) do
        item:removeSelf()  
    end

    -- Stop the music!
    audio.stop(2)
    audio.dispose(loseSound)
    audio.dispose(hitObjectSound)
    audio.dispose(jumpSound)
    audio.dispose(backgroundMusic)
end 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------
 
return scene
