local Sound = {}
local sprintf = Util.sprintf
local printf = Util.printf
local floor = math.floor

function Sound.init()
  if Sound.initialized then
    return
  end
  Sound.initialized = true
  MOAIUntzSystem.initialize(48000)
  Sound.tones = {}
  Sound.playback = {}
  for i = 1, 16 do
    name = sprintf("sounds/breath%03d.wav", i)
    local tone = MOAIUntzSampleBuffer.new()
    tone:load(name)
    Sound.tones[i] = tone
    local playback = MOAIUntzSound.new()
    playback:load(tone)
    Sound.playback[i] = { playback }
  end
end

function Sound.play(tone)
  Sound.init()
  local note = ((floor(tone) - 1) % #Sound.tones) + 1
  local playbacks = Sound.playback[note]
  for i = 1, #playbacks do
    if not playbacks[i]:isPlaying() then
      -- printf("Reusing sound #%d for tone %d.", i, note)
      playbacks[i]:play()
      return
    end
  end
  local playback = MOAIUntzSound.new()
  playback:load(Sound.tones[i])
  playbacks[#playbacks + 1] = playback
  playback:play()
  -- printf("Adding sound #%d for tone %d.", #playbacks, note)
end

function Sound.playoctave(tone, octave)
  tone = ((floor(tone) - 1) % 6) + 1
  octave = (floor(octave) - 1) % 3
  Sound.play(octave * 5 + tone)
end

return Sound
