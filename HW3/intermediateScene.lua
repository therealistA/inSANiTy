local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local livesRemaining = 4
local stage = 1
local life1
local life2
local life3
local life4

local stageText

-- ----------------------------------------------------
-- This function will take the player back to the MENU -- AA
-- -----------------------------------------------------
local function gotoMenu()
    local sceneTransitionOptions = {
        effect = "slideDown",
        time = 500
    }

    composer.gotoScene( "menu", sceneTransitionOptions )
end

-- ----------------------------------------------------
-- This function will take the player to the GAME -- AA
-- -----------------------------------------------------
local function gotoGame()
    local sceneTransitionOptions = {
        effect = "slideUp",
        time = 500,
        params = {
            stage = stage
        }
    }

    print("Navigating to Game view")
    composer.gotoScene( "game", sceneTransitionOptions )
end
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
function scene:create( event )
 
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local sceneGroup = self.view

    -- --------------------------------------
    -- This is the background for this scene -- AA
    -- --------------------------------------

    local background = display.newImageRect( sceneGroup, "chair.png", 450, 750 )
    background.x = display.contentCenterX 
    background.y = display.contentCenterY 

    -- ---------------------------------
    -- These represent the player's lives -- AA
    -- --------------------------------

    local lifeGroup = display.newGroup()

    life1 = display.newImageRect( sceneGroup, "life.png", 70, 70 )
    life1.x = display.contentCenterX - 125
    life1.y = display.contentCenterY - 230
    lifeGroup:insert(life1)

    life2 = display.newImageRect( sceneGroup, "life.png", 70, 70 )
    life2.x = display.contentCenterX - 45
    life2.y = display.contentCenterY - 230
    lifeGroup:insert(life2)

    life3 = display.newImageRect( sceneGroup, "life.png", 70, 70 )
    life3.x = display.contentCenterX + 45
    life3.y = display.contentCenterY - 230
    lifeGroup:insert(life3)

    life4 = display.newImageRect( sceneGroup, "life.png", 70, 70 )
    life4.x = display.contentCenterX + 125
    life4.y = display.contentCenterY - 230
    lifeGroup:insert(life4)

    -- ---------------------------------------------------------------------------------
    -- GAME button widget
    -- I only chanhged this to a widget just so it can match the start button in the menu - AA
    -- ---------------------------------------------------------------------------------    

    local widget = require( "widget" )
 
    -- Function to handle button events
    local function handleButtonEvent( event )
        if ( "ended" == event.phase ) then
            print( "Button was pressed and released" )
        end
    end
 
    -- Create the widget
    gameButton = widget.newButton(
    {
        label = "gameButton",
        onEvent = handleButtonEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 100,
        height = 40,
        cornerRadius = 2,
        fillColor = { default={255,255,0}, over={255,255,0} },
        strokeColor = { default={0,0,0}, over={0,0,0} },
        strokeWidth = 5
    })

    -- Center the button
    gameButton.x = display.contentCenterX + 100
    gameButton.y = display.contentCenterY + 220
     
    -- Change the button's label text
    gameButton:setLabel("GAME")
    gameButton:addEventListener("tap", gotoGame)
    
    -- ---------------------------------------------------------------------------------
    -- MENU button widget
    -- I only chanhged this to a widget just so it can match the start button in the menu -AA
    -- ---------------------------------------------------------------------------------    

    local widget = require( "widget" )
 
    -- Function to handle button events
    local function handleButtonEvent( event )
        if ( "ended" == event.phase ) then
            print( "Button was pressed and released" )
        end
    end
 
    -- Create the widget
    local menuButton = widget.newButton(
    {
        label = "menuButton",
        onEvent = handleButtonEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 100,
        height = 40,
        cornerRadius = 2,
        fillColor = { default={255,255,0}, over={255,255,0} },
        strokeColor = { default={0,0,0}, over={0,0,0} },
        strokeWidth = 5
    })
    
    -- Center the button
    menuButton.x = display.contentCenterX - 100
    menuButton.y = display.contentCenterY + 220
     
    -- Change the button's label text
    menuButton:setLabel( "MENU" )
    menuButton:addEventListener("tap", gotoMenu)

    stageText = display.newText("Stage: "..stage, display.contentCenterX, 230, native.systemFont, 60)
    stageText:setFillColor(0,0,0)
    
    -- Set up the game messages
    win = display.newImageRect(sceneGroup, "won.png", 200, 200 )
    win.x = display.contentCenterX 
    win.y = display.contentCenterY 
    win.isVisible = false 

    gameOver = display.newImageRect(sceneGroup, "gameover.png", 200, 200 )
    gameOver.x = display.contentCenterX 
    gameOver.y = display.contentCenterY    
    gameOver.isVisible = false

    -- --------------------------------------------------------------------
    --This is just putting all of the objects that is the scene in a group
    -- --------------------------------------------------------------------
    sceneGroup:insert(gameButton)
    sceneGroup:insert(menuButton)
    sceneGroup:insert(lifeGroup)
    sceneGroup:insert(stageText)
    sceneGroup:insert(win)
    sceneGroup:insert(gameOver)
end

function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        local params = event.params

        -- if we came from the menu, initialize the game
        if (params.cameFromMenu ~= nil and params.cameFromMenu == true) then
            stage = 1
            livesRemaining = 4
            life1.isVisible = true
            life2.isVisible = true
            life3.isVisible = true
            life4.isVisible = true
            win.isVisible = false
            gameOver.isVisible = false
            gameButton.isVisible = true
            stageText.isVisible = true        
        else
            stage = stage + 1
            print("Stage = "..stage)
        end

        -- if we lost on a stage, decrement the lives
        if (params.decrementLife == true) then
            livesRemaining = livesRemaining - 1
        end

        -- update the stage text
        stageText.text = "Stage: "..stage

        ------------------------------------------------------------------------------------
        -- Logic for hiding life counters -- AM
        ------------------------------------------------------------------------------------
        if(livesRemaining == 3) then
            life4.isVisible = false
        elseif(livesRemaining == 2) then
            life3.isVisible = false
        elseif(livesRemaining == 1) then
            life2.isVisible = false
        elseif(livesRemaining == 0) then
            life1.isVisible = false
            stageText.isVisible = false
    
            --GAME OVER
            gameOver.isVisible = true    
            gameButton.isVisible = false
        end

        if(stage == 11) then            
            life1.isVisible = false
            life2.isVisible = false
            life3.isVisible = false
            life4.isVisible = false
            stageText.isVisible = false
    
            --WIN
            win.isVisible = true    
            gameButton.isVisible = false
        end
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end
 
function scene:hide( event ) 
    local sceneGroup = self.view
    local phase = event.phase
end
 
function scene:destroy( event )
 
    local sceneGroup = self.view
    sceneGroup.remove()   
end
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

--sceneGroup.
-- -----------------------------------------------------------------------------------
 
return scene
