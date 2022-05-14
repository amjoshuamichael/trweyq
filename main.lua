require("notes")
require("graphics")
require("words")
require("utilities")
require("chars")

local playword

function love.load()
    math.randomseed(os.time())

    CreateNoteObject()
    InitializeKeyboard()
    GenerateWordList()
    NewPlayWord()
    InitializeCharsObject()
end

local isInGameState = false

local wordProgress = 1
local playwordScale = 4
function love.draw()
    love.audio.setVolume(1)

    if (isInGameState) then
        RenderKeyboard()

        local wordOffset = Font:getWidth(playword) / 2 * playwordScale
        love.graphics.print(playword, 400 - wordOffset, 100, 0, playwordScale, playwordScale)
        love.graphics.setColor({128, 255, 0})
        local playwordSubSet = playword:sub(0, wordProgress - 1)
        love.graphics.print(playwordSubSet, 400 - wordOffset, 100, 0, playwordScale, playwordScale)

        DoTimer()
        HurtUpdate()
    else 
        love.graphics.setBackgroundColor({255, 255, 255})
        love.graphics.setColor({1, 1, 1})
        local playText = "PRESS ENTER TO START"
        local wordOffset = Font:getWidth(playText) / 2 * playwordScale
        love.graphics.print(playText, 400 - wordOffset, 100, 0, 4, 4)

        if love.keyboard.isDown("return") then isInGameState = true end
    end
end

local timer = 1
local difficulty = 0.01
function DoTimer()
    timer = timer - 0.001
    difficulty = difficulty + 0.0001

    love.graphics.setColor({255, 0, 255})
    love.graphics.polygon("fill", 
        0, love.graphics.getHeight(), 
        0, love.graphics.getHeight() - 20, 
        love.graphics.getWidth() * timer, love.graphics.getHeight() - 20, 
        love.graphics.getWidth() * timer, love.graphics.getHeight())
end

function love.keypressed(key)
    if GameChars[key] == nil then return end
    if not isInGameState then return end

    local currentLetter = playword:sub(wordProgress, wordProgress)

    if wordProgress == #playword + 1 and key == "space" then
        NewPlayWord()
    elseif currentLetter == key then
        wordProgress = wordProgress + 1
        PlaySound()
        timer = math.min(1, timer + 0.01)
    else
        Hurt()
    end

end

function NewPlayWord()
    playword = RandomInArray(WordList)
    wordProgress = 1
    timer = math.min(1, timer + 0.03)
end

function RandomInArray(array)
    local randomIndex = math.random(#array)
    return array[randomIndex]
end

local hurtTimer = 0
function Hurt() 
    timer = timer - 0.1    

    hurtTimer = hurtTimer + 2

    local hurtSound = love.audio.newSource("hurt.wav", "static")
    love.audio.play(hurtSound)
end

function HurtUpdate()
    hurtTimer = math.max(hurtTimer - 0.1, 0)
    
    if timer < 0 then Die() end

    local hurtAmount = hurtTimer
    hurtAmount = hurtAmount + (1 - timer) ^ 4
    local hurtTimerLerp = Lerp(0, 1, 1 / (hurtAmount + 1))
    love.graphics.setBackgroundColor({1, hurtTimerLerp, hurtTimerLerp})
end

function Die()
    isInGameState = false
    
    local dead = love.audio.newSource("hurt.wav", "static")
    love.audio.play(dead)

    timer = 1
    hurtTimer = 0
    NewPlayWord()
end