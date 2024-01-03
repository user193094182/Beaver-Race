
function love.load()
    anim8 = require 'lib/anim8'
    camera = require 'lib/camera'
    suit = require 'lib/suit'

    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())


    beavers = {}
    winner = nil
    beaverInit = false

    numBeavers = 0
    minBeavers = 1
    maxBeavers = 100

    raceLength = 0
    minTime = 1
    maxTime = 300

    beaverSpacing = 0
    raceStart = false

    cam = camera()

    sounds = {}
    sounds.river = love.audio.newSource("audio/stream1.ogg", "static")
    sounds.river:setLooping(true)
    sounds.river:play()

    inputBeavers = {}
    inputBeavers.text = ""
    inputBeavers.visible = true
    inputBeavers.error = ""
    inputBeavers.set = false

    inputTime = {}
    inputTime.text = ""
    inputTime.visible = true
    inputTime.error = ""
    inputTime.set = false

    showUI = true
    start = false
    startError = ""

    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()

    background = {}
    background.spriteSheet = love.graphics.newImage('sprites/Ocean_SpriteSheet.png')
    background.grid = anim8.newGrid(32,32, background.spriteSheet:getWidth(), background.spriteSheet:getHeight())
    background.animations = {}
    background.animations.anim = anim8.newAnimation(background.grid('1-8',2),0.2)

    time = {}
    time.start = 0
    time.stop = 0
    
end

function love.update(dt)
    --TODO: implement countdown timer
    -- or instead of a countdown timer, set the distance instead, put the finish line at that distance, 
    -- once a bever reaches that distance, race ends, theypre the winner

    if showUI then
        renderUI()
    end

    if raceStart and love.timer.getTime() < time.stop then
        max = -1
        for i,beaver in ipairs(beavers) do
            beaver.x = beaver.x + love.math.random(.01, .09)*5
            if beaver.x > max then
                winner = beaver
                max = beaver.x
                cam:lookAt(beaver.x -200, screenHeight/2)
            end
            beaver.animations.right:update(dt)
        end
    elseif raceStart and love.timer.getTime() >= time.stop then
        cam:lookAt(winner.x -200, screenHeight/2)
        winner.animations.right:update(dt)
        winner.x = winner.x + 0.5
    end
    background.animations.anim:update(dt)
end

function love.draw()

    for i = 0, screenWidth/64 do
        for j = 0, screenHeight/64 do
            background.animations.anim:draw(background.spriteSheet,i*64,j*64, nil, 2)
        end
    end

    cam:attach()
    for i=1,#beavers do
        local beaver = beavers[i]
        beaver.animations.right:draw(beaver.spriteSheet, beaver.x, beaver.y, nil, beaver.scale, nil, 200, 32)
        love.graphics.print(beaver.name, beaver.x-325, beaver.y+20)
    end
    cam:detach()

    if inputBeavers.visible or inputTime.visible then
        suit.draw()
    end

    if raceStart and love.timer.getTime() >= time.stop then
        love.graphics.print("Number " .. winner.name .. "is the winner!", screenHeight/2, screenWidth/2)
        --TODO: add play again/reset button here
    end
end

function love.keypressed(key)
    suit.keypressed(key)
end

function love.textinput(t)
    suit.textinput(t)
end

function newBeaver(y, name)
    local beaver = {}
    beaver.y = y
    beaver.x = 500
    beaver.scale = 2
    beaver.scale = 2
    beaver.speed = 1
    beaver.name = name
    beaver.spriteSheet = love.graphics.newImage('sprites/beaver-NESW-rgb.png')
    beaver.grid = anim8.newGrid(64, 64, beaver.spriteSheet:getWidth(), beaver.spriteSheet:getHeight())
    beaver.animations = {}
    beaver.animations.right = anim8.newAnimation(beaver.grid('1-3', 2), 0.2)
    beaver.animations.right:gotoFrame(love.math.random(1,3))
    table.insert(beavers,beaver)
end



function initBeavers(numBeavers)
    newBeaver(20, 1)
    winner = beavers[1]
    for i=1,numBeavers-1 do
        newBeaver(beavers[#beavers].y + beaverSpacing, tostring(i+1))
    end
    beaverInit = true
end

--TODO: need some kind of beaver destructor that clears the beaver list thing table whatever

--TODO: rename renderUI to something else
function renderUI()
    local state

    suit.Label("Number of Beavers:", {align="left"}, 10,0,200,30) 
    state = suit.Input(inputBeavers, 10,25,200,30)
    suit.Label(inputBeavers.error, {align="left"}, 10,50,200,30) 

    suit.Label("Race Length:", {align="left"}, 10, 100, 200, 30)
    state = suit.Input(inputTime, 10, 125, 200, 30)
    suit.Label(inputTime.error, {align="left"}, 10,150,200,30) 

    if suit.Button("Start", 10, 200, 200, 30).hit then
        numBeavers = tonumber(inputBeavers.text)
        if numBeavers == nil or numBeavers > maxBeavers or numBeavers < minBeavers then
            inputBeavers.error = "number of beavers must be beween " .. minBeavers .. " and " .. maxBeavers
            inputBeavers.set = false
        else
            beaverSpacing = (screenHeight-20) / numBeavers
            initBeavers(numBeavers)
            inputBeavers.set = true
        end

        raceLength = tonumber(inputTime.text)
        if raceLength == nil or raceLength > maxTime or raceLength < minTime then
            inputTime.error = "race time must be between " .. minTime .. " and " .. maxTime .. " seconds"
            inputTime.set = false
        else
            inputTime.set = true
        end

        if inputTime.set and inputBeavers.set then
            --TODO: add horn sound effect for race start
            showUI = false
            start = true
            startError = ""
            time.start = love.timer.getTime()
            time.stop = time.start + raceLength
            raceStart = true
        else
            startError = "enter number of beavers and race time"
        end

    end
    suit.Label(startError, 10, 225, 200, 30)
end