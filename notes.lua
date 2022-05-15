SoundLength = 22060
SoundLengthT = SoundLength * 2

function CreateNoteObject()
	Notes = {}

	local a4 = 440
	local diff = (2^(1/12))
	Notes[1] = a4

	for i = 2, 48 do
		Notes[i] = Notes[i - 1] * diff
	end
	
	Notes.soundDatas = {}
	for i, v in ipairs(Notes) do
		Notes.soundDatas[i] = love.sound.newSoundData(SoundLength, SoundLengthT, 16, 1)
		local wavelength = (SoundLengthT/v)/math.pi*2;

		for s = 0, SoundLength-1 do
		   local sin = math.sqrt(math.sin(s/wavelength) * (1 - s / SoundLength))
		   Notes.soundDatas[i]:setSample(s, sin)
		end
	end
	
	Notes.sources = {}
	for i, v in ipairs(Notes.soundDatas) do
		Notes.sources[i] = love.audio.newSource(v)
	end
end

function PlayNote(pitch)
	local source = Notes.sources[pitch]
	if source.isPlaying then
		love.audio.stop(source)
	end
	love.audio.play(source)
end