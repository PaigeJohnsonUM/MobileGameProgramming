local counter = 0
local sheetOptions=
{
	frames=
	{
		{  --1) Egg
			x=0,
			y=0,
			width=196,
			height=216,
		},
		{  --2)sidepan1
			x=230,
			y=0,
			width=189,
			height=172
		},
		{  --)sidepan2
			x=457,
			y=0,
			width=187,
			height=178
		},
		{ --3)duck
			x=0,
			y=208,
			width=222,
			height=217,
		},
	},
}

local objectSheet = graphics.newImageSheet( "ss1.png", sheetOptions)

local backGroup = display.newGroup()

local background = display.newImageRect("Background.jpg", 800, 1400)
background.x = display.contentCenterX
background.y= display.contentCenterY
backGroup:insert(background)

local mainGroup = display.newGroup()
local x = 1
Egg = display.newImageRect(mainGroup, objectSheet, x, 300, 300)
Egg.x = display.contentCenterX
Egg.y = display.contentCenterY

tapcount = display.newText(counter, display.contentCenterX, 400, native.systemFont, 18) 
tapcount:setFillColor(1,0,1)

local function updateText()
	tapcount.text = counter
end
	

local function tapper()
	counter = counter + 1
	tapcount.text = counter
end
Egg:addEventListener( "tap", tapper)








