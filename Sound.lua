local Sound = {}
local sprintf = Util.sprintf
local printf = Util.printf
local floor = math.floor

local effects = { 'key', 'space', 'return', 'coin' }

function Sound.init()
  if Sound.initialized then
    return
  end
  Sound.initialized = true
  MOAIUntzSystem.initialize(48000)
  Sound.tones = {}
  Sound.playback = {}
  Sound.effects = {}
  Sound.effect_playback = {}
  for i = 1, 6 do
    name = sprintf("sounds/breath%03d.wav", i)
    local tone = MOAIUntzSampleBuffer.new()
    tone:load(name)
    Sound.tones[i] = tone
    local playback = MOAIUntzSound.new()
    playback:load(tone)
    Sound.playback[i] = { playback }
  end
  for i = 1, #effects do
    name = sprintf("sounds/%s.wav", effects[i])
    local tone = MOAIUntzSampleBuffer.new()
    tone:load(name)
    Sound.effects[effects[i]] = tone
    local playback = MOAIUntzSound.new()
    playback:load(tone)
    Sound.effect_playback[effects[i]] = { playback }
  end
end

function Sound.play(tone)
  Sound.init()
  local note
  local playbacks
  if type(tone) == 'number' then
    note = ((floor(tone) - 1) % #Sound.tones) + 1
    playbacks = Sound.playback[note]
  else
    playbacks = Sound.effect_playback[tone]
  end
  for i = 1, #playbacks do
    if not playbacks[i]:isPlaying() then
      -- printf("Reusing sound #%d for tone %d.", i, note)
      playbacks[i]:play()
      return
    end
  end
  local playback = MOAIUntzSound.new()
  if type(tone) == 'number' then
    playback:load(Sound.tones[note])
  else
    playback:load(Sound.effects[tone])
  end
  playbacks[#playbacks + 1] = playback
  playback:play()
  -- printf("Adding sound #%d for tone %s.", #playbacks, tostring(note or tone))
end

function Sound.playoctave(tone, octave)
  tone = ((floor(tone) - 1) % 6) + 1
  octave = (floor(octave) - 1) % 3
  Sound.play(octave * 5 + tone)
end

return Sound
