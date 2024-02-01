practice_mode = false

max_level = nil
max_index = nil

local Lang = 29
local LangObj

if (nil == max_level) then
  local inf = io.open("numoff.sav", "r")
  if (nil == inf) then
    max_level = 2
    max_index = 1
  else
    max_level,max_index = inf:read("*number", "*number")
    inf:close()
  end
end

Flicker = {}

Flicker.OnCreate = function(param)
  param.time = 0
end

Flicker.OnStep = function(param)
  local id = param._id
  param.time = param.time + 1
  if (60 < param.time) then
    param.time = 0
  end
  local d = math.floor(0xf0 * (1 - math.sin(math.pi * param.time/60)))
  Good.SetBgColor(id, 0xffff00 + d * 0x1000000)
end

function SetLang()
  LangObj = Good.GenObj(28, Lang)
  Good.SetPos(LangObj, 15, 4)
end

Title = {}

function Title.OnCreate(param)
  practice_mode = false
  SetLang()
  param.timer = nil
  if (2 == max_level and 1 == max_index) then
    return
  end
  local SW, SH = Good.GetWindowSize()
  local slv = string.format('LV%d-%d', max_level - 1, max_index)
  local o = GenStrObj(-1, SW - 16 * string.len(slv), SH - 32, slv, nil, nil, nil, 0xffff6a00)
  Good.SetScale(o, 0.6, 0.6)
end

function Title.OnStep(param)
  if (Input.IsKeyPushed(Input.ESCAPE)) then
    Good.Exit()
  elseif (Input.IsKeyPushed(Input.ANY)) then
    if (Input.IsKeyPushed(Input.LBUTTON)) then
      local mx, my = Input.GetMousePos()
      local x1, y1 = Good.GetPos(28)
      local x2, y2 = Good.GetPos(33)
      if (PtInRect(mx, my, x1, y1, x1 + 75, y1 + 65)) then
        if (31 == Lang) then
          Lang = 29
        else
          Lang = Lang + 1
        end
        Good.FireUserIntEvent(30000 + Lang)
        if (nil ~= LangObj) then
          Good.KillObj(LangObj)
        end
        SetLang()
        return
      elseif (PtInRect(mx, my, x2, y2, x2 + 64, y2 + 64)) then
        practice_mode = true
      end
    end
    Sound.PlaySound(19)
    param.timer = 0
  end
  if (nil ~= param.timer) then
    param.timer = param.timer + 1
    if (40 == param.timer) then
      Good.GenObj(-1, 2)                  -- Start game.
    end
  end
end
