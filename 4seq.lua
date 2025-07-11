-- 4seq
-- arc based 4x prolly sequencer
--
-- by 256k
engine.name = 'PolyPerc'
MusicUtil = require("musicutil")

local arc4 = arc.connect()
local mididev = midi.connect()
local rootNote = 64

-- CONSTANTS
local PROB_THRESHOLD_LIMIT = 101
-- ---------
local problist = {}
local thold = {}
local playhead = {}

function tholdInit(tholdVal)
  for t=1,4 do
    thold[t] = tholdVal
  end
end

function playheadInit()
  for p=1,4 do
    playhead[p] = 1
  end
end

function playheadInc(playheadNum, seqLength)
  local ph = playhead[playheadNum]
  if ph >= seqLength then 
    playhead[playheadNum] = 1 
    return
  end
  playhead[playheadNum] = ph + 1
end


function problistInit(thld_limit)
  for a=1,4 do
    problist[a] = {}  
    for i=1,64 do
      problist[a][i] = math.random(thld_limit)
    end
  end
end

function init()
  problistInit(PROB_THRESHOLD_LIMIT)
  tholdInit(PROB_THRESHOLD_LIMIT)
  playheadInit()
  
  for i=1,4 do
  drawRingProbSeq(i)
  end
  
  clock.run(function()
    while true do
      clock.sync(1/4)
      for i=1,4 do
        playheadInc(i, 64)
        drawRingProbSeq(i)
        -- print(problist[i][playhead[i]])
        if problist[i][playhead[i]] > thold[i] then
        engine.hz(MusicUtil.note_num_to_freq(rootNote) * i)
        end

  end
    end
  end)
end

mididev.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    rootNote = d.note
  end
end

function arc.delta(n,d)
  print("THOLD: ", thold[n])
  thold[n] = util.clamp((thold[n] + d / 16 ), 0, PROB_THRESHOLD_LIMIT )
  drawRingProbSeq(n)
end

function drawRingProbSeq(ring)
for i=1,64 do
  local ledVal
  if problist[ring][i] > thold[ring] then
    ledVal = 10
    else ledVal = 0
  end
  if i == playhead[ring] then ledVal = 15 end
  arc4:led(ring, i, ledVal )
end
arc4:refresh()
end
