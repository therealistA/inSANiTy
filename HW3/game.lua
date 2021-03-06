-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require("composer")
local widget = require( "widget" )
local physics = require ("physics") -- AA
local scene = composer.newScene()

local stageNumber = 1
local numberOfStages = 10

local itemToFindIndex = 0

local stageItemNumbers = {}
local verticalTransformations = {}
local itemsToRemove = {}

local imageSheet

local touchEnabled = true

local winImage
local loseImage

local decrementLife = false
local sceneMovedAwayFrom = false;

local progressTimer

local function getRandomNumber(min, max)
	local number = math.random(min, max)
	--print("Random number: "..number)
	return number
end

local function gotoIntermediate()
	timer.cancel(progressTimer)

    local sceneTransitionOptions = {
        effect = "slideDown",
        time = 500,
        params = { decrementLife = decrementLife }
    }

    composer.gotoScene( "intermediateScene", sceneTransitionOptions )
end

local function getRandomNumberWithExclusions(min, max, exclusions)
	local number = getRandomNumber(min, max)

	for _, listItem in pairs(exclusions) do
      	if listItem == number then
      		-- Recursively call this function until a random number 
      		-- is generated that is not contained in the exclusions list
        	return getRandomNumberWithExclusions(min, max, exclusions)
      	end
    end

	return number
end
-- Function to handle button events
local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
    print( "Button was pressed and released" )
    end
end

function itemTouchHandler(event)
	-- if the scene is enabled
	if touchEnabled == true then
		-- if the correct item was found, show the win image and move to the next scene
		if itemToFindIndex == event.target.index then
			print("Found the correct item")

			winImage.x = event.target.x
			winImage.y = event.target.y
			winImage.isVisible = true

			local soundEffect = audio.loadSound("win.wav") 
			audio.play(soundEffect)

			decrementLife = false			
			sceneMovedAwayFrom = true
			timer.performWithDelay(800, function()gotoIntermediate() end, 1)
			touchEnabled = false
			-- if the incorrect item was found, show the lose image and move to the next scene
		else
			print("Did not find the correct item")

			loseImage.x = event.target.x
			loseImage.y = event.target.y
			loseImage.isVisible = true

			local soundEffect = audio.loadSound("lose.wav") 
			audio.play(soundEffect)

			decrementLife = true
			sceneMovedAwayFrom = true
			timer.performWithDelay(800, function()gotoIntermediate() end, 1)
			touchEnabled = false
		end
	end
end

-- Gets the image at the specified index from the imageSheet and places it at the coordinates passed in
function getImage(index, x, y, touchEnabled)
	local item = display.newImage(imageSheet, index, x, y + verticalTransformations[index])
	item.index = index

	-- if the touchEnabled flag is true, add an event listener
	if touchEnabled == true then
		item:addEventListener("tap", itemTouchHandler)
	end

	-- reverse the image if the index is for one of the reversed images
	if index >= 19 then
		item.xScale = -1
	end

	return item
end

-- ---------------------------------------------------------
-- This function stops the bird once it has been tapped on  -- AA
-- ---------------------------------------------------------
local function stopBird(event)
    event.target:pause()
    physics.pause()
    timer.performWithDelay(800, function() physics.start() end, 1)
    event.target:play()
end

-- ---------------------------------------------------------
-- This function will turn the bird around when it hits a wall -- AA
-- ---------------------------------------------------------
local function onLocalCollision( self, event )
    if ( event.phase == "began" ) then
    elseif ( event.phase == "ended" ) then
        if (event.other.myName == "left")then
            self.xScale = 1;
        elseif (event.other.myName == "right")then
            self.xScale = -1;
        end
    end
end

-- ---------------------------------------------------------
-- This will control the movement of the progress bar -- AA
-- ---------------------------------------------------------
local function moveProgressBar(event)
    p = progressBarRect:getProgress();
    p = p + 1 / 8
    if (p == 1 and sceneMovedAwayFrom == false) then
    	decrementLife = true
        gotoIntermediate()
    else
        progressBarRect:setProgress(p)
    end
end

function scene:create( event )
	local sceneGroup = self.view

	-- set up the table containing the number of items in the house for each level
	for stage = 1, numberOfStages do
		if (stage <= 3) then			
			stageItemNumbers[stage] = getRandomNumber(3, 5)
		elseif (stage <= 6) then
			stageItemNumbers[stage] = getRandomNumber(6, 8)			
		elseif (stage <= 10) then
			stageItemNumbers[stage] = getRandomNumber(9, 15)		
		end
	end

	-- set up the image sheet coordinates 
	local options =
	{
		frames =
		{
			{ x = 550, y = 0, width = 260, height = 200 },  -- 1 - House 1 Background
			{ x = 810, y = 0, width = 260, height = 200 },  -- 2 - House 2 Background
			{ x = 1068, y = 0, width = 260, height = 200 }, -- 3 - Red Square Background
			{ x = 368, y = 8, width = 41, height = 41 },  -- 4 - Green Circle
			{ x = 413, y = 10, width = 35, height = 35 },  -- 5 - Red X
			{ x = 148, y = 22, width = 41, height = 38 },  -- 6 - Bird 1
			{ x = 191, y = 22, width = 39, height = 36 },  -- 7 - Bird 2
			{ x = 379, y = 122, width = 17, height = 41 },  -- 8 - Bottle 1
			{ x = 403, y = 122, width = 17, height = 41 },  -- 9 - Bottle 2
			{ x = 429, y = 115, width = 36, height = 21 },  -- 10 - Hat 1
			{ x = 429, y = 137, width = 36, height = 21 },  -- 11 - Hat 2
			{ x = 429, y = 159, width = 36, height = 21 },  -- 12 - Hat 3
			{ x = 473, y = 111, width = 24, height = 24 },  -- 13 - Cup 1
			{ x = 473, y = 136, width = 24, height = 23 },  -- 14 - Cup 2
			{ x = 473, y = 160, width = 24, height = 23 },  -- 15 - Cup 3
			{ x = 511, y = 93, width = 22, height = 31 },  -- 16 - Pot 1
			{ x = 512, y = 125, width = 22, height = 32 },  -- 17 - Pot 2
			{ x = 510, y = 158, width = 22, height = 32 },  -- 18 - Pot 3
			-- Note that the reversed frames are not actually reversed, logic in the getImage function
			-- will reverse them when creating the image.
			{ x = 379, y = 122, width = 17, height = 41 },  -- 19 - Bottle 1 Reverse
			-- Bottle 2 reverse would be the same thing
			{ x = 429, y = 115, width = 36, height = 21 },  -- 20 - Hat 1 Reverse
			{ x = 429, y = 137, width = 36, height = 21 },  -- 21 - Hat 2 Reverse
			{ x = 429, y = 159, width = 36, height = 21 },  -- 22 - Hat 3 Reverse
			{ x = 473, y = 111, width = 24, height = 24 },  -- 23 - Cup 1 Reverse
			{ x = 473, y = 136, width = 24, height = 23 },  -- 24 - Cup 2 Reverse
			{ x = 473, y = 160, width = 24, height = 23 },  -- 25 - Cup 3 Reverse
			{ x = 511, y = 93, width = 22, height = 31 },  -- 26 - Pot 1 Reverse
			{ x = 512, y = 125, width = 22, height = 32 },  -- 27 - Pot 2 Reverse
			{ x = 510, y = 158, width = 22, height = 32 },  -- 28 - Pot 3 Reverse
		}
	}
	
	-- initialize the image sheet
	imageSheet = graphics.newImageSheet("marioware.png", options)

	seqData = 
    {
        {name = "flying", start = 6, count = 2, time = 200}
    }

	birdCollision = { categoryBits = 2, maskBits = 1}

	-- set up tranformation values so items appear consistently where we want them to in the house
	verticalTransformations[8] = -10
	verticalTransformations[9] = -10
	verticalTransformations[10] = 0
	verticalTransformations[11] = 0
	verticalTransformations[12] = 0
	verticalTransformations[13] = -2
	verticalTransformations[14] = -2
	verticalTransformations[15] = -2
	verticalTransformations[16] = -6
	verticalTransformations[17] = -6
	verticalTransformations[18] = -6
	verticalTransformations[19] = -10
	verticalTransformations[20] = 0
	verticalTransformations[21] = 0
	verticalTransformations[22] = 0
	verticalTransformations[23] = -2
	verticalTransformations[24] = -2
	verticalTransformations[25] = -2
	verticalTransformations[26] = -6
	verticalTransformations[27] = -6
	verticalTransformations[28] = -6

	-- setup the scene background images and text blocks
	local topBackground = display.newImage(imageSheet, 3, display.contentCenterX, 115)
	topBackground.xScale = 1.25
	topBackground.yScale = 1.25

	stageText = display.newText("Stage "..stageNumber, display.contentCenterX, 30, native.systemFont, 24)
	stageText:setFillColor(0, 0, 0)

	houseBackground = display.newImage(imageSheet, 1, display.contentCenterX, 355)
	houseBackground.xScale = 1.25
	houseBackground.yScale = 1.25

	local findText = display.newText("Find!", display.contentCenterX, 150, native.systemFont, 18)
	findText:setFillColor(0, 0, 0)

   -- -----------------------------------
   -- This is making the progress bar -- AA
   -- -----------------------------------
    progressBarRect = widget.newProgressView(
        {
            left = display.contentCenterX - 160, 
            top = display.contentCenterY + 238, 
            width = 320
        }
    )

	sceneGroup:insert(topBackground)
	sceneGroup:insert(stageText)
	sceneGroup:insert(houseBackground)
	sceneGroup:insert(findText)
	sceneGroup:insert(progressBarRect)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		local params = event.params

		-- set up scene items
		sceneMovedAwayFrom = false

		if (params ~= nil and params.stage ~= nil) then
			stageNumber = params.stage
			stageText.text = "Stage "..stageNumber
		end

		-- Randomly get an index for an item that use player needs to find
		itemToFindIndex = getRandomNumber(8, 28)

		-- display the image in the top section
		itemToFind = getImage(itemToFindIndex, display.contentCenterX, 110, false)
		itemsToRemove[0] = itemToFind
		sceneGroup:insert(itemToFind)

		-- initialize the list of items in the house to find the item from
		itemsInHouse = {}

		-- include the randomly selected item to find in the list
		itemsInHouse[1] = itemToFindIndex

		local numberOfItemsInHouse = stageItemNumbers[stageNumber]

		-- Get a random index for an image that will be placed in the house
		for i = 2, numberOfItemsInHouse do
			itemsInHouse[i] = getRandomNumberWithExclusions(8, 28, itemsInHouse)
		end

		-- Swap the first item in the list with a randomly selected item in the list
		-- This prevents to item to select from always appearing in the same position
		local swapIndex = getRandomNumber(1, numberOfItemsInHouse)
		local tempItem = itemsInHouse[swapIndex]
		itemsInHouse[swapIndex] = itemsInHouse[1]
		itemsInHouse[1] = tempItem

		-- Place items in the house for the user to find
		if (stageNumber == 1) then	
      		local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 356, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[4] ~= nil then
				local item4 = getImage(itemsInHouse[4], 100, 356, true)
				itemsToRemove[4] = item4
				sceneGroup:insert(item4)
			end

			if itemsInHouse[5] ~= nil then
				local item5 = getImage(itemsInHouse[5], 260, 308, true)
				itemsToRemove[5] = item5
				sceneGroup:insert(item5)
			end
		elseif (stageNumber == 2) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 125, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[4] ~= nil then
				local item4 = getImage(itemsInHouse[4], 90, 358, true)
				itemsToRemove[4] = item4
				sceneGroup:insert(item4)
			end

			if itemsInHouse[5] ~= nil then
				local item5 = getImage(itemsInHouse[5], 260, 308, true)
				itemsToRemove[5] = item5
				sceneGroup:insert(item5)
			end
		elseif (stageNumber == 3) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[4] ~= nil then
				local item4 = getImage(itemsInHouse[4], 100, 358, true)
				itemsToRemove[4] = item4
				sceneGroup:insert(item4)
			end

			if itemsInHouse[5] ~= nil then
				local item5 = getImage(itemsInHouse[5], 280, 308, true)
				itemsToRemove[5] = item5
				sceneGroup:insert(item5)
			end
		elseif (stageNumber == 4) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			
			local item4 = getImage(itemsInHouse[4], 100, 358, true)
			itemsToRemove[4] = item4
			sceneGroup:insert(item4)
			

			
			local item5 = getImage(itemsInHouse[5], 250, 308, true) --240, 219
			itemsToRemove[5] = item5
			sceneGroup:insert(item5)
			
			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[6] ~= nil then
				local item6 = getImage(itemsInHouse[6], 290, 430, true)
				itemsToRemove[6] = item6
				sceneGroup:insert(item6)
			end

			if itemsInHouse[7] ~= nil then
				local item7 = getImage(itemsInHouse[7], 65, 358, true)
				itemsToRemove[7] = item7
				sceneGroup:insert(item7)
			end

			if itemsInHouse[8] ~= nil then
				local item8 = getImage(itemsInHouse[8], 280, 308, true)
				itemsToRemove[8] = item8
				sceneGroup:insert(item8)
			end

		elseif (stageNumber == 5) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			
			local item4 = getImage(itemsInHouse[4], 100, 358, true)
			itemsToRemove[4] = item4
			sceneGroup:insert(item4)
			

			
			local item5 = getImage(itemsInHouse[5], 250, 308, true) --240, 219
			itemsToRemove[5] = item5
			sceneGroup:insert(item5)
			
			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[6] ~= nil then
				local item6 = getImage(itemsInHouse[6], 290, 430, true)
				itemsToRemove[6] = item6
				sceneGroup:insert(item6)
			end

			if itemsInHouse[7] ~= nil then
				local item7 = getImage(itemsInHouse[7], 60, 358, true)
				itemsToRemove[7] = item7
				sceneGroup:insert(item7)
			end

			if itemsInHouse[8] ~= nil then
				local item8 = getImage(itemsInHouse[8], 285, 308, true)
				itemsToRemove[8] = item8
				sceneGroup:insert(item8)
			end
		elseif (stageNumber == 6) then
			local item1 = getImage(itemsInHouse[1], 255, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			
			local item4 = getImage(itemsInHouse[4], 100, 358, true)
			itemsToRemove[4] = item4
			sceneGroup:insert(item4)
			

			
			local item5 = getImage(itemsInHouse[5], 250, 308, true) --240, 219
			itemsToRemove[5] = item5
			sceneGroup:insert(item5)
			
			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[6] ~= nil then
				local item6 = getImage(itemsInHouse[6], 290, 430, true)
				itemsToRemove[6] = item6
				sceneGroup:insert(item6)
			end

			if itemsInHouse[7] ~= nil then
				local item7 = getImage(itemsInHouse[7], 70, 358, true)
				itemsToRemove[7] = item7
				sceneGroup:insert(item7)
			end

			if itemsInHouse[8] ~= nil then
				local item8 = getImage(itemsInHouse[8], 280, 308, true)
				itemsToRemove[8] = item8
				sceneGroup:insert(item8)
			end
		elseif (stageNumber == 7) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			local item4 = getImage(itemsInHouse[4], 95, 358, true)
			itemsToRemove[4] = item4
			sceneGroup:insert(item4)
			
			local item5 = getImage(itemsInHouse[5], 250, 308, true) 
			itemsToRemove[5] = item5
			sceneGroup:insert(item5)
			
			local item6 = getImage(itemsInHouse[6], 290, 430, true)
			itemsToRemove[6] = item6
			sceneGroup:insert(item6)

			local item7 = getImage(itemsInHouse[7], 65, 358, true)
			itemsToRemove[7] = item7
			sceneGroup:insert(item7)
			
			local item8 = getImage(itemsInHouse[8], 280, 308, true)
			itemsToRemove[8] = item8
			sceneGroup:insert(item8)
			

			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[9] ~= nil then
				local item9 = getImage(itemsInHouse[9], 210, 460, true)
				itemsToRemove[9] = item9
				sceneGroup:insert(item9)
			end

			if itemsInHouse[10] ~= nil then
				local item10 = getImage(itemsInHouse[10], 30, 460, true)
				itemsToRemove[10] = item10
				sceneGroup:insert(item10)
			end

			if itemsInHouse[11] ~= nil then
				local item11 = getImage(itemsInHouse[11], 180, 460, true)
				itemsToRemove[11] = item11
				sceneGroup:insert(item11)
			end
			if itemsInHouse[12] ~= nil then
				local item12 = getImage(itemsInHouse[12], 60, 460, true)
				itemsToRemove[12] = item12
				sceneGroup:insert(item12)
			end

			if itemsInHouse[13] ~= nil then
				local item13 = getImage(itemsInHouse[13], 150, 460, true)
				itemsToRemove[13] = item13
				sceneGroup:insert(item13)
			end

			if itemsInHouse[14] ~= nil then
				local item14 = getImage(itemsInHouse[14], 90, 460, true)
				itemsToRemove[14] = item14
				sceneGroup:insert(item14)
			end

			if itemsInHouse[15] ~= nil then
				local item15 = getImage(itemsInHouse[15], 120, 460, true)
				itemsToRemove[15] = item15
				sceneGroup:insert(item15)
			end

		elseif (stageNumber == 8) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			local item4 = getImage(itemsInHouse[4], 100, 358, true)
			itemsToRemove[4] = item4
			sceneGroup:insert(item4)
			
			local item5 = getImage(itemsInHouse[5], 250, 308, true) 
			itemsToRemove[5] = item5
			sceneGroup:insert(item5)
			
			local item6 = getImage(itemsInHouse[6], 295, 430, true)
			itemsToRemove[6] = item6
			sceneGroup:insert(item6)

			local item7 = getImage(itemsInHouse[7], 70, 358, true)
			itemsToRemove[7] = item7
			sceneGroup:insert(item7)
			
			local item8 = getImage(itemsInHouse[8], 280, 308, true)
			itemsToRemove[8] = item8
			sceneGroup:insert(item8)
			

			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[9] ~= nil then
				local item9 = getImage(itemsInHouse[9], 210, 460, true)
				itemsToRemove[9] = item9
				sceneGroup:insert(item9)
			end

			if itemsInHouse[10] ~= nil then
				local item10 = getImage(itemsInHouse[10], 55, 316, true)
				itemsToRemove[10] = item10
				sceneGroup:insert(item10)
			end

			if itemsInHouse[11] ~= nil then
				local item11 = getImage(itemsInHouse[11], 180, 460, true)
				itemsToRemove[11] = item11
				sceneGroup:insert(item11)
			end
			if itemsInHouse[12] ~= nil then
				local item12 = getImage(itemsInHouse[12], 60, 460, true)
				itemsToRemove[12] = item12
				sceneGroup:insert(item12)
			end

			if itemsInHouse[13] ~= nil then
				local item13 = getImage(itemsInHouse[13], 150, 460, true)
				itemsToRemove[13] = item13
				sceneGroup:insert(item13)
			end

			if itemsInHouse[14] ~= nil then
				local item14 = getImage(itemsInHouse[14], 90, 460, true)
				itemsToRemove[14] = item14
				sceneGroup:insert(item14)
			end

			if itemsInHouse[15] ~= nil then
				local item15 = getImage(itemsInHouse[15], 120, 460, true)
				itemsToRemove[15] = item15
				sceneGroup:insert(item15)
			end
		elseif (stageNumber == 9) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 240, 460, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			local item4 = getImage(itemsInHouse[4], 100, 358, true)
			itemsToRemove[4] = item4
			sceneGroup:insert(item4)
			
			local item5 = getImage(itemsInHouse[5], 250, 308, true) 
			itemsToRemove[5] = item5
			sceneGroup:insert(item5)
			
			local item6 = getImage(itemsInHouse[6], 270, 460, true)
			itemsToRemove[6] = item6
			sceneGroup:insert(item6)

			local item7 = getImage(itemsInHouse[7], 70, 358, true)
			itemsToRemove[7] = item7
			sceneGroup:insert(item7)
			
			local item8 = getImage(itemsInHouse[8], 280, 308, true)
			itemsToRemove[8] = item8
			sceneGroup:insert(item8)
			

			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[9] ~= nil then
				local item9 = getImage(itemsInHouse[9], 210, 460, true)
				itemsToRemove[9] = item9
				sceneGroup:insert(item9)
			end

			if itemsInHouse[10] ~= nil then
				local item10 = getImage(itemsInHouse[10], 55, 318, true)
				itemsToRemove[10] = item10
				sceneGroup:insert(item10)
			end

			if itemsInHouse[11] ~= nil then
				local item11 = getImage(itemsInHouse[11], 180, 460, true)
				itemsToRemove[11] = item11
				sceneGroup:insert(item11)
			end
			if itemsInHouse[12] ~= nil then
				local item12 = getImage(itemsInHouse[12], 60, 460, true)
				itemsToRemove[12] = item12
				sceneGroup:insert(item12)
			end

			if itemsInHouse[13] ~= nil then
				local item13 = getImage(itemsInHouse[13], 150, 460, true)
				itemsToRemove[13] = item13
				sceneGroup:insert(item13)
			end

			if itemsInHouse[14] ~= nil then
				local item14 = getImage(itemsInHouse[14], 90, 460, true)
				itemsToRemove[14] = item14
				sceneGroup:insert(item14)
			end

			if itemsInHouse[15] ~= nil then
				local item15 = getImage(itemsInHouse[15], 120, 460, true)
				itemsToRemove[15] = item15
				sceneGroup:insert(item15)
			end
		elseif (stageNumber == 10) then
			local item1 = getImage(itemsInHouse[1], 260, 348, true)
			itemsToRemove[1] = item1
			sceneGroup:insert(item1)

			local item2 = getImage(itemsInHouse[2], 260, 430, true)
			itemsToRemove[2] = item2
			sceneGroup:insert(item2)

			local item3 = getImage(itemsInHouse[3], 130, 358, true)
			itemsToRemove[3] = item3
			sceneGroup:insert(item3)

			local item4 = getImage(itemsInHouse[4], 100, 358, true)
			itemsToRemove[4] = item4
			sceneGroup:insert(item4)
			
			local item5 = getImage(itemsInHouse[5], 250, 308, true) 
			itemsToRemove[5] = item5
			sceneGroup:insert(item5)
			
			local item6 = getImage(itemsInHouse[6], 290, 430, true)
			itemsToRemove[6] = item6
			sceneGroup:insert(item6)

			local item7 = getImage(itemsInHouse[7], 70, 358, true)
			itemsToRemove[7] = item7
			sceneGroup:insert(item7)
			
			local item8 = getImage(itemsInHouse[8], 280, 308, true)
			itemsToRemove[8] = item8
			sceneGroup:insert(item8)
			

			-- Check for nil value before attempting to add the item to the view
			if itemsInHouse[9] ~= nil then
				local item9 = getImage(itemsInHouse[9], 210, 460, true)
				itemsToRemove[9] = item9
				sceneGroup:insert(item9)
			end

			if itemsInHouse[10] ~= nil then
				local item10 = getImage(itemsInHouse[10], 60, 318, true)
				itemsToRemove[10] = item10
				sceneGroup:insert(item10)
			end

			if itemsInHouse[11] ~= nil then
				local item11 = getImage(itemsInHouse[11], 180, 460, true)
				itemsToRemove[11] = item11
				sceneGroup:insert(item11)
			end
			if itemsInHouse[12] ~= nil then
				local item12 = getImage(itemsInHouse[12], 60, 460, true)
				itemsToRemove[12] = item12
				sceneGroup:insert(item12)
			end

			if itemsInHouse[13] ~= nil then
				local item13 = getImage(itemsInHouse[13], 150, 460, true)
				itemsToRemove[13] = item13
				sceneGroup:insert(item13)
			end

			if itemsInHouse[14] ~= nil then
				local item14 = getImage(itemsInHouse[14], 90, 460, true)
				itemsToRemove[14] = item14
				sceneGroup:insert(item14)
			end

			if itemsInHouse[15] ~= nil then
				local item15 = getImage(itemsInHouse[15], 120, 460, true)
				itemsToRemove[15] = item15
				sceneGroup:insert(item15)
			end
      	end

      	-- creat the win and lose images and hide them until needed
		winImage = display.newImage(imageSheet, 4)
		winImage.isVisible = false

		loseImage = display.newImage(imageSheet, 5)
		loseImage.isVisible = false

		sceneGroup:insert(winImage)
		sceneGroup:insert(loseImage)

-- -----------------------------------
-- BIRD
-- -----------------------------------
		
		-- setup the bounding box
		local bottom = display.newRect(display.contentCenterX,486,display.actualContentWidth,1)
		local top = display.newRect(display.contentCenterX,236,display.actualContentWidth,1)
		local right = display.newRect(319,display.contentCenterY+125,1,240)
		right:setFillColor(0,0,0)
		local left = display.newRect(1,display.contentCenterY+125,1,240)
		left:setFillColor(0,0,0)
		bottom.myName = "bottom"
		top.myName = "top"
		right.myName = "right"
		left.myName = "left"

		sceneGroup:insert(bottom)
		sceneGroup:insert(top)
		sceneGroup:insert(right)
		sceneGroup:insert(left)

		physics.start()
        physics.setGravity(0,0)

        physics.addBody(bottom, "static", {friction=0, bounce=1.0})
		physics.addBody(top, "static", {friction=0, bounce=1.0})
		physics.addBody(right, "static", {friction=0, bounce=1.0})
		physics.addBody(left, "static", {friction=0, bounce=1.0})

        bird2 = display.newGroup()

        -- if past stage 4, add one bird
        if(stageNumber >= 4)then
            local num = 1;

            -- if past stage 7, add a second bird
            if (stageNumber >= 7) then 
            	num = 2; 
            end

            for i=1, num do
                local bird = display.newSprite (imageSheet, seqData);   --initialize
                physics.addBody(bird, "dynamic", {bounce=1.0, filter = birdCollision})
                bird:setSequence("flying");                           --set the Y anchor
                bird.x = display.contentCenterX;                                   --set the X and Y coordinates
                bird.y = 350;
                bird.isFixedRotation = true;

                sceneGroup:insert(bird);
                bird:play();
                bird:toFront();
                bird:setLinearVelocity(75 * i, 75 * i * math.pow(-1, i%2))
                bird.collision = onLocalCollision
                bird:addEventListener( "collision" )
                bird:addEventListener("tap", stopBird);

                bird2:insert(bird);
            end

			sceneGroup:insert(bird2)
        end

        -- reset the progress bar
        progressBarRect:setProgress(0);        
	elseif ( phase == "did" ) then
		progressTimer = timer.performWithDelay(1000, moveProgressBar, 8)
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		winImage.isVisible = false
		loseImage.isVisible = false

		for i = 0, stageItemNumbers[stageNumber] do
			itemsToRemove[i]:removeSelf()
		end	

		touchEnabled = true
	elseif ( phase == "did" ) then
		bird2:removeSelf();
		physics.stop();
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	sceneGroup.remove()
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene

