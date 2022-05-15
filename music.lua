MenuMusic = {name = "menu_music", bpm = 120}
GameMusic = {name = "game_music", bpm = 118}
local currentMusic = nil
local currentMusicName

local allNoteSeries = {
    game_music_intro = {
        {
            loopCount = 2,
            notes = {
                {b = 4, n = {18, 21, 25, 28}},
                {b = 4, n = {16, 20, 23, 25}},
                {b = 4, n = {18, 20, 23, 25}},
                {b = 4, n = {20, 23, 25, 27}},
            }
        },
        {
            loopCount = 4,
            notes = {
                {b = 1.5, n = {21, 25, 28, 32}},
                {b = 2, n = {20, 23, 27, 30}},
                {b = 2.5, n = {22, 27, 30}},
                {b = 2, n = {20, 24, 27, 32}},
            }
        }
    },
    game_music_loop = {
        {
            loopCount = 8,
            notes = {
                {b = 1.5, n = {18, 21, 25, 28}},
                {b = 2, n = {16, 20, 23, 25}},
                {b = 2.5, n = {18, 20, 23, 25}},
                {b = 2, n = {20, 23, 25, 27}},
            }
        },
    },
    menu_music_intro = {
        {
            loopCount = 1,
            notes = {
                {b = 4, n = {16, 20, 23, 28}},
                {b = 4, n = {15, 18, 23, 27}},
                {b = 4, n = {17, 20, 25, 29}},
                {b = 4, n = {16, 21, 25, 28}},
            }
        }
    },
    menu_music_loop = {
        {
            loopCount = 1,
            notes = {
                {b = 4, n = {16, 20, 23, 28}},
                {b = 4, n = {15, 18, 23, 27}},
                {b = 4, n = {17, 20, 25, 29}},
                {b = 4, n = {16, 21, 25, 28}},
            }
        }
    },
}

function InitializeMusic()
    GameMusic["intro"] = love.audio.newSource("songs/gamesong_intro.wav", "stream")
    GameMusic["loop"] = love.audio.newSource("songs/gamesong_loop.wav", "stream")
    GameMusic["loop"]:setLooping(true)

    MenuMusic["intro"] = love.audio.newSource("songs/menusong_intro.wav", "stream")
    MenuMusic["loop"] = love.audio.newSource("songs/menusong_loop.wav", "stream")
    MenuMusic["loop"]:setLooping(true)

    local newAllNoteSeries = {}

    for seriesName, series in pairs(allNoteSeries) do
        local newSeries = {}
        local currentBeat = 0

        for _, loop in pairs(series) do
            for l=1, loop.loopCount do
                for _, chord in ipairs(loop.notes) do
                    currentBeat = currentBeat + chord.b
                    table.insert(newSeries,
                        {b = currentBeat, n = chord.n}
                    )
                end
            end
        end

        newAllNoteSeries[seriesName] = newSeries
    end

    print(newAllNoteSeries["game_music_loop"])
    allNoteSeries = newAllNoteSeries
end

function SetMusic(music)
    love.audio.stop()
    currentMusic = music

    love.audio.play(currentMusic["intro"])
    currentMusicName = currentMusic["name"] .. "_intro"
end

function UpdateMusic()
    if currentMusic == nil then return end

    if not currentMusic["intro"]:isPlaying() and not currentMusic["loop"]:isPlaying() then
        -- No music is playing, move into loop

        love.audio.play(currentMusic["loop"])
        currentMusicName = currentMusic["name"] .. "_loop"
    end
end

local sampleRate = 44100

function DoRightKeySound()
    local time
   
    if currentMusic["intro"]:isPlaying() then
        time = currentMusic["intro"]:tell()
    else
        time = currentMusic["loop"]:tell()
    end

    local beat = time / 60 * currentMusic.bpm

	local noteSeries = allNoteSeries[currentMusicName]

    local chordToUse
    for _, chord in ipairs(noteSeries) do
        local beatOfChord = chord.b

        if beatOfChord > beat then
            chordToUse = chord.n
            break
        end
    end

    print(beat, chordToUse[1], chordToUse[2])

    local randomIndex = math.random(#chordToUse)
    PlayNote(chordToUse[randomIndex])
end