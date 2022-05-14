local keys = {
    { letter = "q", x = 20, y = 00 },
    { letter = "w", x = 30, y = 00 },
    { letter = "e", x = 40, y = 00 },
    { letter = "r", x = 50, y = 00 },
    { letter = "t", x = 60, y = 00 },
    { letter = "y", x = 70, y = 00 },
    { letter = "u", x = 80, y = 00 },
    { letter = "i", x = 90, y = 00 },
    { letter = "o", x = 100, y = 00 },
    { letter = "p", x = 110, y = 00 },
    { letter = "backspace", x = 120, y = 00 },
    { letter = "a", x = 22, y = 10 },
    { letter = "s", x = 32, y = 10 },
    { letter = "d", x = 42, y = 10 },
    { letter = "f", x = 52, y = 10 },
    { letter = "g", x = 62, y = 10 },
    { letter = "h", x = 72, y = 10 },
    { letter = "j", x = 82, y = 10 },
    { letter = "k", x = 92, y = 10 },
    { letter = "l", x = 102, y = 10 },
    { letter = "'", x = 112, y = 10 },
    { letter = "z", x = 25, y = 20 },
    { letter = "x", x = 35, y = 20 },
    { letter = "c", x = 45, y = 20 },
    { letter = "v", x = 55, y = 20 },
    { letter = "b", x = 65, y = 20 },
    { letter = "n", x = 75, y = 20 },
    { letter = "m", x = 85, y = 20 },
    { letter = ",", x = 95, y = 20 },
    { letter = ".", x = 105, y = 20 },
    { letter = "space", x = 45, y = 30 },
}

local scale = 4
local timeSincePressed = {}
local pressAnimLength = 1000

function InitializeKeyboard()
    love.audio.setVolume(0)

    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    Font = love.graphics.newImageFont("imagefont.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"")

    love.graphics.setFont(Font, scale)
end

function RenderKeyboard()
    love.graphics.translate(100, 300)

    for i, key in ipairs(keys) do
        if love.keyboard.isDown(key.letter) then
            if timeSincePressed[key.letter] == nil
                or timeSincePressed[key.letter].timeSinceUp ~= 0 then
                timeSincePressed[key.letter] = { timeSinceUp = 0, timeSinceDown = 0 }
            end
            love.graphics.setColor({ 255, 0, 0 })
        else
            love.graphics.setColor({ 0, 255, 255 })
        end

        for letter, time in pairs(timeSincePressed) do
            if time.timeSinceUp > 1 then
                timeSincePressed[letter] = nil
            else
                if love.keyboard.isDown(letter) then
                    timeSincePressed[letter].timeSinceDown = time.timeSinceDown + 1 / pressAnimLength
                else
                    timeSincePressed[letter].timeSinceUp = time.timeSinceUp + 1 / pressAnimLength
                end
            end
        end

        key_formatted = key.letter
            :gsub("backspace", "del")
            :gsub("lshift", "shift")
            :gsub("rshift", "shift")

        local pushPullAmount = 2
        local pushx = 0
        local pushy = 0
        for _, outsidekey in ipairs(keys) do
            local anim = timeSincePressed[outsidekey.letter]

            if outsidekey.letter ~= key.letter and anim ~= nil then
                local function timeSinceDownFunc(timeSinceDown)
                    return 1 / (-timeSinceDown * 8 - 0.2) + 5
                end

                local pushpull
                if anim.timeSinceUp > 0 then
                    local ogpushpuull = timeSinceDownFunc(anim.timeSinceDown)
                    pushpull = (-0.8 * math.min(anim.timeSinceUp * 3, 1) + 1) ^ 5 * ogpushpuull
                else
                    pushpull = timeSinceDownFunc(anim.timeSinceDown)
                end

                local distWeight = 1 / Distance(key.x, key.y, outsidekey.x, outsidekey.y)
                pushx = pushx + pushpull * pushPullAmount * distWeight * (key.x - outsidekey.x)
                pushy = pushy + pushpull * pushPullAmount * distWeight * (key.y - outsidekey.y)
            end
        end

        local keypushed = { x = key.x + pushx, y = key.y + pushy }

        if timeSincePressed[key.letter] == nil then
            love.graphics.print(key_formatted, keypushed.x * scale, keypushed.y * scale, 0, scale, scale)
        else
            local function pushedScaleFunc(time) 
                return (math.sqrt(1 / (time * 10 + 1)) + 1) / 2 * scale
            end

            local time
            local scale_bounced
            if timeSincePressed[key.letter].timeSinceUp == 0 then
                time = timeSincePressed[key.letter].timeSinceDown
                scale_bounced = pushedScaleFunc(time)
            else
                time = 1 - math.min(timeSincePressed[key.letter].timeSinceUp * 2, 1)
                local ogscale_bounced = pushedScaleFunc(timeSincePressed[key.letter].timeSinceDown)
                scale_bounced = Lerp(ogscale_bounced, scale, (2 / (time - 2) + 2) ^ 0.5)
            end

            local x = key.x + (scale - scale_bounced) * string.len(key_formatted) + pushx
            local y = key.y + (scale - scale_bounced) * 2 + pushy
            love.graphics.print(key_formatted, x * scale, y * scale, 0, scale_bounced, scale_bounced)
        end
    end

    love.graphics.translate(-100, -300)
    love.graphics.setColor({255, 255, 255})
end

function GetKeyPos(letter)
    for i, key in ipairs(keys) do
        if key.letter == letter then return key end
    end
end

function Distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

function Lerp(a,b,t) return a * (1-t) + b * t end