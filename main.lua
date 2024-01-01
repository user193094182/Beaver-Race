
function love.load()
    anim8 = require 'lib/anim8'
    camera = require 'lib/camera'
    suit = require 'lib/suit'

    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())

    beavers = {}
    beaverInit = false

    numBeavers = 0
    minBeavers = 1
    maxBeavers = 10

    raceTime = nil
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
end

function love.update(dt)

    --TODO: implement countdown timer
    if showUI then
        renderUI()
    end

    max = -1
    for i,beaver in ipairs(beavers) do
        beaver.x = beaver.x + love.math.random(.01, .09)*5
        if beaver.x > max then
            max = beaver.x
            cam:lookAt(beaver.x -200, screenHeight/2)
        end
        beaver.animations.right:update(dt)
    end
end

function love.draw()
    --TODO: add background

    cam:attach()
    for i=1,#beavers do
        local beaver = beavers[i]
        beaver.animations.right:draw(beaver.spriteSheet, beaver.x, beaver.y, nil, beaver.scale, nil, 200, 32)
    end
    cam:detach()

    if inputBeavers.visible or inputTime.visible then
        suit.draw()
    end
end

function love.keypressed(key)
    suit.keypressed(key)
end

function love.textinput(t)
    suit.textinput(t)
end

function newBeaver(y)
    local beaver = {}
    beaver.y = y
    beaver.x = 500
    beaver.scale = 2
    beaver.scale = 2
    beaver.speed = 1
    beaver.spriteSheet = love.graphics.newImage('sprites/beaver-NESW-rgb.png')
    beaver.grid = anim8.newGrid(64, 64, beaver.spriteSheet:getWidth(), beaver.spriteSheet:getHeight())
    beaver.animations = {}
    beaver.animations.right = anim8.newAnimation(beaver.grid('1-3', 2), 0.2)
    beaver.animations.right:gotoFrame(love.math.random(1,3))
    table.insert(beavers,beaver)
end

function initBeavers(numBeavers)
    newBeaver(20)
    for i=1,numBeavers-1 do
        newBeaver(beavers[#beavers].y + beaverSpacing)
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

    suit.Label("Time:", {align="left"}, 10, 100, 200, 30)
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

        raceTime = tonumber(inputTime.text)
        if raceTime == nil or raceTime > maxTime or raceTime < minTime then
            inputTime.error = "race time must be between " .. minTime .. " and " .. maxTime .. " seconds"
            inputTime.set = false
        else
            inputTime.set = true
        end

        if inputTime.set and inputBeavers.set then
            showUI = false
            start = true
            startError = ""
            --TODO: add horn sound effect for race start
        else
            startError = "enter number of beavers and race time"
        end

    end
    suit.Label(startError, 10, 225, 200, 30)
end