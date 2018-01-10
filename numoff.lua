
local SW, SH = Good.GetWindowSize()
local BORDER = 30
local OFFSET_X = BORDER
local OFFSET_Y = BORDER - 10
local MAP_W = SW - 2 * BORDER
local MAP_H = SH - 2 * BORDER

local level = 2
local N
local map, index
local dx, dy
local curr_index

local tick
local timer = 0
local otimer
local olv
local dark

function saveGame()
  if (practice_mode) then
    return
  end
  if (level > max_level) then
    max_level = level
    max_index = curr_index
  elseif (level == max_level and curr_index > max_index) then
    max_index = curr_index
  else
    return
  end
  if (curr_index == N + 1) then
    max_index = N
  end
  local o = GenStrObj(-1, 0, 0, 'New Record!', nil, nil, nil, 0xffff0000)
  local outf = io.open("numoff.sav", "w")
  outf:write(max_level," ", max_index)
  outf:close()
end

math.randomseed(os.clock())

Game = {}

function NextLevelBouns(Lv)
  return math.floor(Lv * Lv / 2) + Lv - 1
end

function GenTimerStrObj(LevelUp)
  if (practice_mode) then
    return
  end
  local t = math.min(99, math.floor(100 * tick / 60))
  local s = string.format('%d.%02d', timer, t)
  if (LevelUp) then
    s = s .. string.format(' + %d', NextLevelBouns(level + 1))
  end
  local clr = nil
  if (3 > timer) then
    clr = 0xffff0000
  end
  return GenStrObj(-1, 5, SH - 40, s, nil, nil, nil, clr)
end

function GenLevelStrObj()
  local slv = string.format('LV%d-%d', level - 1, curr_index)
  return GenStrObj(-1, SW - 16 * string.len(slv) - 5, SH - 40, slv)
end

function Game.OnCreate(param)
  param.p = nil
  N = level * level
  dx = math.floor(MAP_W / level)
  dy = math.floor(MAP_H / level)

  map = {}
  index = {}
  curr_index = 1

  for i = 0, N - 1 do
    map[i] = nil
    index[i] = i + 1
  end

  for i = 0, N - 1 do
    local r = math.random(i + 1) - 1
    local n = index[r]
    index[r] = index[i]
    index[i] = n
  end

  for i = 0, N - 1 do
    local row = math.floor(i / level)
    local col = i % level
    local color
    if (0 == ((col + row) % 2)) then
      color = 0xFFFFECD6
    else
      color = 0xFFFFE9DD
    end
    local o = GenColorObj(-1, dx - 1, dy - 1, color)
    local x = OFFSET_X + col * dx
    local y = OFFSET_Y + row * dy
    local str = tostring(index[i])
    Good.SetPos(o, x, y)
    local sx = (dx - string.len(str) * 16) / 2
    local sy = (dy - 32) / 2
    local s = GenStrObj(o, sx, sy, str, nil, nil, nil, 0xffff0000)
    map[i] = o
  end

  tick = 60
  timer = timer + NextLevelBouns(level)

  otimer = GenTimerStrObj(false)
  olv = GenLevelStrObj()
end

function OnStepPause(param)
  if (Input.IsKeyPushed(Input.ESCAPE)) then
    level = 2
    Good.GenObj(-1, 6)                  -- Title.
    Game.OnStep = OnStepDefault
  elseif (Input.IsKeyPushed(Input.LBUTTON)) then
    Good.KillObj(dark)
    Game.OnStep = OnStepDefault         -- Continue.
  end
end

function OnStepDefault(param)
  if (curr_index == N + 1 or 0 == timer) then
    return
  end

  if (Input.IsKeyPushed(Input.ESCAPE)) then
    if (practice_mode) then
      level = 2
      timer = 0
      Good.GenObj(-1, 6)                  -- Title.
    else
      dark = GenColorObj(-1, SW, SH, 0xFE000000)
      local s = GenTexObj(dark, 27, 84, 31)
      Good.SetPos(s, (SW - 82)/2, 220)
      Game.OnStep = OnStepPause
    end
    return
  end

  tick = tick - 1
  if (0 == tick) then
    tick = 60
    if (not practice_mode) then
      timer = timer - 1
      if (0 == timer) then
        tick = 0
        Good.KillObj(otimer)
        otimer = GenTimerStrObj(false)
        Good.FireUserIntEvent(10000)
        GenColorObj(-1, SW, SH, 0xAA000000)
        local s = GenTexObj(-1, 13, 302, 56) -- Game over.
        Good.SetPos(s, 60, 160)
        saveGame()
        tick = 60
        Game.OnStep = OnStepOver
        return
      end
    end
  end

  if (nil ~= otimer) then
    Good.KillObj(otimer)
  end
  otimer = GenTimerStrObj(false)

  if (Input.IsKeyPushed(Input.LBUTTON)) then
    local x, y = Input.GetMousePos()
    local row = math.floor((y - OFFSET_Y) / dy)
    local col = math.floor((x - OFFSET_X) / dy)
    local i = col + row * level
    if (nil == map[i]) then
      return
    end
    if (curr_index ~= index[i]) then
      Sound.PlaySound(20)
      return
    end
    Good.FireUserIntEvent(index[i])
    Good.SetScript(map[i], 'Clear')
    map[i] = nil
    curr_index = curr_index + 1
    if (curr_index == N + 1) then
      if (nil ~= otimer) then
        Good.KillObj(otimer)
      end
      otimer = GenTimerStrObj(true)
      local s = GenTexObj(-1, 14, 362, 37) -- Level complete.
      Good.SetPos(s, 25, 160)
      Good.FireUserIntEvent(20000)
      param.p = Stge.RunScript('_rain')
      saveGame()
      tick = 60
      Game.OnStep = OnStepComplete
    else
      Good.KillObj(olv)
      olv = GenLevelStrObj()
    end
  end
end

function OnStepOver(param)
  if (Input.IsKeyPushed(Input.ESCAPE)) then
    return
  end

  if (0 < tick) then
    tick = tick - 1
    if (0 == tick) then
      local s1 = GenTexObj(-1, 27, 84, 31)
      Good.SetPos(s1, (SW - 82)/2, 220)
    end
    return
  end
  if (Input.IsKeyPushed(Input.LBUTTON)) then
    level = 2
    Good.GenObj(-1, 6)                  -- Title.
    Game.OnStep = OnStepDefault
  end
end

function OnStepComplete(param)
  if (Input.IsKeyPushed(Input.ESCAPE)) then
    return
  end

  if (0 < tick) then
    tick = tick - 1
    if (0 == tick) then
      local s = GenTexObj(-1, 27, 84, 31)
      Good.SetPos(s, (SW - 82)/2, 220)
    end
    return
  end
  if (Input.IsKeyPushed(Input.LBUTTON)) then
    if (practice_mode and 6 == level) then
      level = 2
    else
      level = level + 1
    end
    if (nil ~= param.p) then
      Stge.KillTask(param.p)
    end
    Good.GenObj(-1, 2)                  -- New game.
    Game.OnStep = OnStepDefault
  end
end

bcolor = {0xffff0000,0xff00ff00,0xffffff00,0xff0000ff,0xffff00ff,0xffffffff}

Game.OnNewParticle = function(param, particle)
  local o = Good.GenObj(-1, 22 + math.random(3))
  Good.SetBgColor(o, bcolor[math.random(6)])
  Stge.BindParticle(particle, o)
end

Game.OnKillParticle = function(param, particle)
  Good.KillObj(Stge.GetParticleBind(particle))
end

Clear = {}

function Clear.OnStep(param)
  local id = param._id

  if (nil == param.step) then
    Good.KillAllChild(id)
    param.step = 0
    return
  end

  param.step = param.step + 1
  if (8 == param.step) then
    Good.KillObj(id)
    return
  end

  local d = math.floor(0xf0 * (1 - math.sin(math.pi/2 * param.step/10)))
  Good.SetBgColor(id, 0xffffff + d * 0x1000000)
end

Game.OnStep = OnStepDefault
