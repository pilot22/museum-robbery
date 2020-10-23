-- Initializing some vars
mrobbery.laser_icon = Material("materials/museum_robbery/laser_icon.png")
LocalPlayer().CloseReseller = false
LocalPlayer().ErrPerc = false

-- DotsPart --
local delay = 0
local current_dot = current_dot or ""

local function computeDots()
  if CurTime() < delay then return end

  if current_dot == "..." then
      current_dot = ""
  end

  current_dot = current_dot .. "."
  delay = CurTime() + .8
end
----

local function MakeMaterial(path, crc, ent)
  local mat = Material("data/" .. path)

  CreateMaterial(crc, "VertexLitGeneric", { -- Creating the material to use it on the painting.
    ["$basetexture"] = mat:GetTexture("$basetexture"):GetName(),
    ["$model"] = 1,
    ["$translucent"] = 0,
    ["$vertexalpha"] = 0,
    ["$alpha"] = 0,
    ["$vertexcolor"] = 1
  })

  if IsValid(ent) then
    ent:SetSubMaterial(1, "!" .. crc)
  end
end

local function CalcView(ent, entangle, LerpV, calcname)
  hook.Add("CalcView", calcname, function()
      local view = {}

      if IsValid(ent) then
          LerpV = LerpVector(FrameTime() * 8, LerpV, ent:GetPos() + entangle:Up() * 15 - entangle:Forward() * 25)
          view.origin = LerpV
          view.angles = entangle
          view.fov = 95
          view.drawviewer = false

          return view
      end
  end)
end

net.Receive("MRB:DLMAT", function()
  local url = net.ReadString()
  local ent = net.ReadEntity() or nil
  local crc = util.CRC(url)
  local filedir = string.format("museum_robbery/mats/%s.jpg", crc)

  if not file.Exists(filedir, "DATA") then
      http.Fetch(url, function(data)
        if not file.Exists("museum_robbery/mats/", "DATA") then
          file.CreateDir("museum_robbery/mats/")
        end
        file.Write(filedir, data)
        MakeMaterial(filedir, crc, ent)
      end)
  else
    if not (IsValid(Material("data/" .. filedir))) then
      MakeMaterial(filedir, crc, ent)
    end
  end
end)

----------------
-- CONFIG NET --
----------------

net.Receive("MRB:UI:CFG", function()
  local curoptions = net.ReadTable()

  local Base = vgui.Create("DFrame")
  Base:SetSize(ScrW() * .45, ScrH() * .6)
  Base:SetPos(ScrW() * .275, ScrH() * .2)
  Base:SetTitle("")
  Base:SetDraggable(false)
  Base:MakePopup()
  Base:ShowCloseButton(false)
  Base.Paint = function(_, w, h)
      draw.RoundedBoxEx(15, 0, 0, w, h, Color(52, 73, 94),true, true, true, true)
      draw.RoundedBoxEx(15, 0, 0, w, h * .1, Color(52, 152, 219, 255), true, true)
      draw.SimpleTextOutlined(mrobbery.language[mrobberycfg.language]["config_title"], "Trebuchet24b", w / 2, h * .05, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
      draw.SimpleText(utf8.char(0xf66f), "icon3", w / 2 - (ScreenScale(14) * 5), h * .05, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end

  local exitbtn = vgui.Create("DButton", Base)
  exitbtn:SetSize(Base:GetWide() * .05, Base:GetTall() * .05)
  exitbtn:SetPos(Base:GetWide() * .95, Base:GetTall() * .02)
  exitbtn:SetText("")
  exitbtn.Paint = function(_, w, h)
      draw.SimpleText(utf8.char(0xf2f5), "icon", w / 2, h / 3, Color(231, 76, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  exitbtn.DoClick = function()
      surface.PlaySound("museum_robbery/btn_light.ogg")
      Base:Close()
  end

  local helpbtn = vgui.Create("DButton", Base)
  helpbtn:SetSize(Base:GetWide() * .05, Base:GetTall() * .05)
  helpbtn:SetPos(Base:GetWide() * .9, Base:GetTall() * .02)
  helpbtn:SetText("")
  helpbtn.isactivated = false
  helpbtn:SetTooltip(mrobbery.language[mrobberycfg.language]["visual_guide"] or "")
  helpbtn.Paint = function(_, w, h)
      draw.SimpleText(utf8.char(0xf0ad), "icon", w / 2, h / 3, helpbtn.isactivated and Color(230, 126, 34) or Color(211, 84, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  helpbtn.DoClick = function()
    surface.PlaySound("museum_robbery/btn_light.ogg")
    if helpbtn.isactivated then
      helpbtn.isactivated = false
    else
      helpbtn.isactivated = true
    end
  end

  local parent = vgui.Create("DScrollPanel", Base)
  parent:SetPos(Base:GetWide() * 0, Base:GetTall() * .125)
  parent:SetSize(Base:GetWide() * 1, Base:GetTall() * .8)

  local sbar = parent:GetVBar() -- Just to disable the vbar
  function sbar:Paint() end
  function sbar.btnGrip:Paint() end
  function sbar.btnUp:Paint()	end
  function sbar.btnDown:Paint() end

  surface.SetFont("Trebuchet24b") -- This is for the surface.GetTextSize (at line 143 and 247)

  for k, v in SortedPairs(curoptions) do
    local x = surface.GetTextSize(mrobbery.language[mrobberycfg.language][tostring(k)])

    local df = parent:Add("DPanel")
    df.Paint = function(_, w, h)
      draw.RoundedBox(5, w*.04 + x, h * .3, w * .875 - (w*.05 + x), h * .2, helpbtn.isactivated and Color(52, 152, 219) or Color(0,0,0,0))
    end
    df:Dock(TOP)

    local txt = vgui.Create("mrstxt", df)
    txt:SetPos(0, df:GetTall() * 15)
    txt:SetColor(Color(189, 195, 199, 255))
    txt:SetTxt(mrobbery.language[mrobberycfg.language][tostring(k)] or "")
    txt:SizeToContents()
    txt:Dock(TOP)
    txt:DockMargin(mrobbery.f.RespX(10), 0, 0, 0)

    if isstring(v) then
      local txte = vgui.Create("DTextEntry", df)
      txte:SetAllowNonAsciiCharacters(true)
      txte:SetNumeric(false)
      txte:SetText("")
      txte:SetValue(v)
      txte:SetDrawLanguageID(false)
      txte:SetSize(parent:GetWide() * .15, 22)
      txte:SetPos(parent:GetWide() * .85,  0)
      function txte:OnChange()
        curoptions[k] = self:GetValue()
      end
    elseif isnumber(v) then
      local txte = vgui.Create("DTextEntry", df)
      txte:SetAllowNonAsciiCharacters(false)
      txte:SetNumeric(true)
      txte:SetText("")
      txte:SetValue(v)
      txte:SetSize(parent:GetWide() * .15, 22)
      txte:SetPos(parent:GetWide() * .85, 0)
      function txte:OnChange()
        curoptions[k] = tonumber(self:GetValue())
      end
    elseif isbool(v) then
      local btn = vgui.Create("mrbtn", df)
      btn:SetText("")
      btn:SetState(v)
      btn:SetSize(parent:GetWide() * .15, 22)
      btn:SetPos(parent:GetWide() * .85, 0)
      btn.DoClick = function()
        surface.PlaySound("museum_robbery/btn_heavy.ogg")
      	btn:UpdateState()
        curoptions[k] = btn:GetState()
      end
    elseif istable(v) then
      local btn = vgui.Create("DButton", df)
      btn:SetText("")
      btn:SetSize(parent:GetWide() * .15, 22)
      btn:SetPos(parent:GetWide() * .85, 0)
      btn.DoClick = function()
        surface.PlaySound("museum_robbery/btn_heavy.ogg")
        if k == "admingroups" then
          local Menu = DermaMenu()
          Menu:SetMaxHeight(ScrH())

          local men, mene = Menu:AddSubMenu(mrobbery.language[mrobberycfg.language][k .. "2"] or "nil")
          mene:SetIcon("icon16/user_suit.png")

          for k2, _ in SortedPairs(ULib.ucl.groups) do
            if curoptions[k][k2] == true then
              men:AddOption(k2, function()
                curoptions[k][k2] = false
              end):SetIcon("icon16/tick.png")
            else
              men:AddOption(k2, function()
                curoptions[k][k2] = true
              end):SetIcon("icon16/cross.png")
            end
          end
          Menu:Open()
        elseif k == "teamro" then
          local Menu = DermaMenu()
          Menu:Center()

          local men, mene = Menu:AddSubMenu(mrobbery.language[mrobberycfg.language][k .. "2"] or "nil")
          mene:SetIcon("icon16/user_suit.png")

          for k2, v in pairs(RPExtraTeams) do
            if curoptions[k][team.GetName(k2)] == true then
              men:AddOption(team.GetName(k2), function()
                curoptions[k][team.GetName(k2)] = false
              end):SetIcon("icon16/tick.png")
            else
              men:AddOption(team.GetName(k2), function()
                curoptions[k][team.GetName(k2)] = true
              end):SetIcon("icon16/cross.png")
            end
          end
          Menu:Open()
        end
      end
      btn.Paint = function(_, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(189, 195, 199))
        draw.SimpleText(mrobbery.language[mrobberycfg.language]["clickme"], "DermaDefault", w / 2 - (string.len(mrobbery.language[mrobberycfg.language]["clickme"]) / 2), h / 2, color_black, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
      end
    end
  end

  local sizex, _ = surface.GetTextSize(mrobbery.language[mrobberycfg.language]["config_title"])

  local saveconfig = vgui.Create("DButton", Base)
  saveconfig:SetSize(sizex, Base:GetTall() * .05)
  saveconfig:SetPos(Base:GetWide() / 2 - (saveconfig:GetWide() / 2), Base:GetTall() * .94)
  saveconfig:SetText("")
  saveconfig.Paint = function(_, w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(39, 174, 96, 255))
    draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(46, 204, 113, 255))
    draw.SimpleText(mrobbery.language[mrobberycfg.language]["save_config"], "Trebuchet24b", w/2, h / 2, Color(236, 240, 241), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  saveconfig.DoClick = function()
    surface.PlaySound("museum_robbery/btn_light.ogg")

    net.Start("MRB:UI:CFG:UPDATE")
    net.WriteTable(curoptions)
    net.SendToServer()
    Base:Close()
  end
end)

--------------------------
-- UI COMPUTER HACK NET --
--------------------------

net.Receive("MRB:UI:PC:HACK", function()
  local computer = net.ReadEntity()

  local hack_time = mrobberycfg.hacktime
  local hackinprogress = false
  local started_time = 0

  local entangle = computer:GetAngles()
  entangle:RotateAroundAxis(entangle:Up(), 180)

  local LerpV = LocalPlayer():EyePos()

  CalcView(computer, entangle, LerpV, "MBR:CalcViewUIH") -- Call a function that create an CalcView hook.

  local BaseH = vgui.Create("DFrame")
  BaseH:SetSize(mrobbery.f.RespX(0), mrobbery.f.RespY(0))
  BaseH:SetPos(ScrW() / 2 - ((ScrW() * .3) / 2) - mrobbery.f.RespX(10), ScrH() * .3 - mrobbery.f.RespX(45))
  BaseH:MakePopup()
  BaseH:SetDraggable(false)
  BaseH:ShowCloseButton(false)
  BaseH:SetTitle("")

  function BaseH:animclose()
    self:SizeTo(1, 1, .25, 0, -1, function()
      if IsValid(self) then
        self:Close() hook.Remove("CalcView", "MBR:CalcViewUIH")
      end
    end)
  end

  function BaseH:OnClose()
      self:SizeTo(0,0,1,.2,-1)
      hook.Remove("CalcView", "MBR:CalcViewUIH")
  end

  BaseH:SizeTo(ScrW() * .295, ScrH() * .4, 1, .2, -1, function()
      local closebtn = vgui.Create("DButton", BaseH)
      closebtn:SetSize(mrobbery.f.RespX(64), mrobbery.f.RespY(64))
      closebtn:SetPos(BaseH:GetWide() - (closebtn:GetWide() + mrobbery.f.RespX(8)), BaseH:GetWide() * .01)
      closebtn:SetText("")
      closebtn.Paint = function(_, w, _)
          draw.SimpleText(utf8.char(0xf011), "icon3", w / 3.5, 5.5, Color(255, 107, 107, 255))
      end
      closebtn.DoClick = function()
          BaseH:animclose()
          surface.PlaySound("museum_robbery/btn_light.ogg")

          net.Start("MRB:UI:HACK:Cancel")
          net.SendToServer()
      end

      local hackbtn = vgui.Create("DButton", BaseH)
      hackbtn:SetPos(0, BaseH:GetTall() * .3)
      hackbtn:SetSize(BaseH:GetWide(), BaseH:GetTall() * .1)
      hackbtn:SetText("")
      hackbtn.Paint = function(s,w,h)
        if hackinprogress == true then
          computeDots()
          hackbtn:SetCursor("arrow")
          draw.SimpleText(mrobbery.language[mrobberycfg.language]["hack_ipg"] .. current_dot, "Trebuchet24b", w * .5, h / 2, Color(131, 149, 167,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif hackinprogress == 1 then
          computeDots()
          hackbtn:SetCursor("arrow")
          draw.SimpleText(mrobbery.language[mrobberycfg.language]["hacked"] .. current_dot, "Trebuchet24b", w * .5,  h / 2, Color(131, 149, 167,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          if s:IsHovered() then
            draw.SimpleText(mrobbery.language[mrobberycfg.language]["hack_computer"], "Trebuchet24b", w * .5, h / 2, Color(200, 214, 229,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          else
            draw.SimpleText(mrobbery.language[mrobberycfg.language]["hack_computer"], "Trebuchet24b", w * .5,  h / 2, Color(131, 149, 167,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
        end
      end
      hackbtn.DoClick = function()
        net.Start("MRB:UI:HACK:Start")
        net.SendToServer()

        started_time = CurTime() -- Defined as local at line 291

        timer.Simple(.1, function()
          hackinprogress = true -- Defined as local at line 290
        end)
      end

      local hackpr = vgui.Create("DPanel", BaseH)
      hackpr:SetSize(BaseH:GetWide() / 2, BaseH:GetTall() * .15)
      hackpr:SetPos(BaseH:GetWide() / 2 - (hackpr:GetWide() / 2), BaseH:GetTall() * .45)
      hackpr.timer_progress = 0
      hackpr.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))

        if hackinprogress == true then
          local tpsdp = computer:GetStartHackT() - mrobberycfg.hacktime
  				hackpr.timer_progress = math.Clamp((CurTime() - tpsdp) / (CurTime() + mrobberycfg.hacktime - CurTime()), 0, 1)
        end

        draw.RoundedBox(0, 0, 0, w * hackpr.timer_progress, h, Color(46, 204, 113))
      end

      local txt = vgui.Create("DPanel", BaseH)
      txt:SetSize(BaseH:GetWide() * .2, BaseH:GetTall() * .2)
      txt:SetPos(BaseH:GetWide() / 2 - (txt:GetWide() / 2), BaseH:GetTall() * .6)
      txt.Paint = function(s, w, h)
        if hackinprogress == true then
          draw.SimpleText(tostring(mrobberycfg.hacktime - (math.Round(hackpr.timer_progress, 2) * mrobberycfg.hacktime)) .. "s", "Trebuchet24", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end

      function hackpr:Think()
        if (hackinprogress == true) and (hackpr.timer_progress == 1) and (CurTime() - started_time > 1) then
          hackinprogress = 1
          timer.Simple(3, function() BaseH:animclose() end)
        end
      end
  end)
  function BaseH:Paint(w, h)
      draw.RoundedBox(0, 3, 3, w, h, Color(34, 47, 62, 255))
  end
  BaseH:SetAlpha(0)
  BaseH:AlphaTo(255, 1, .2)
end)

---------------------
-- UI COMPUTER NET --
---------------------

net.Receive("MRB:UI:PC", function()
  if IsValid(Base) then Base:Remove() end

  local current_hover
  local hover_text

  local ent = net.ReadEntity()
  local anims = net.ReadBool()

  local entangle = ent:GetAngles()
  entangle:RotateAroundAxis(entangle:Up(), 180)

  local LerpV = LocalPlayer():EyePos()

  CalcView(ent, entangle, LerpV, "MBR:CalcViewUI") -- Call a function that create an CalcView hook.

  local time = 0
  if anims == true then
    time = 1
  end

  local Base = vgui.Create("DFrame")
  Base:SetSize(mrobbery.f.RespX(0), mrobbery.f.RespY(0))
  Base:SetPos(ScrW() / 2 - ((ScrW() * .3) / 2) - mrobbery.f.RespX(10), ScrH() * .3 - mrobbery.f.RespX(50))
  Base:MakePopup()
  Base:SetDraggable(false)
  Base:ShowCloseButton(false)
  Base:SetTitle("")
  function Base:animclose()
    self:SizeTo(1, 1, .25, 0, -1, function()
      if IsValid(self) then
        self:Close()
        hook.Remove("CalcView", "MBR:CalcViewUI")
      end
    end)
  end
  Base:SizeTo(ScrW() * .30, ScrH() * .41, time, .2, -1, function()
      local closebtn = vgui.Create("DButton", Base)
      closebtn:SetSize(mrobbery.f.RespX(64), mrobbery.f.RespY(64))
      closebtn:SetPos(Base:GetWide() - (closebtn:GetWide() + mrobbery.f.RespX(8)), Base:GetWide() * .01)
      closebtn:SetText("")
      closebtn.Paint = function(_, w, _)
          draw.SimpleText(utf8.char(0xf011), "icon3", w / 3.5, 5.5, Color(255, 107, 107, 255))
      end
      closebtn.DoClick = function()
          surface.PlaySound("museum_robbery/btn_light.ogg")

          Base:animclose()
      end

      local t = vgui.Create("DPanel", Base)
      t:SetSize(Base:GetWide(), Base:GetTall() * .3)
      t:SetPos(0, Base:GetTall() * .8)
      t.Paint = function(_, w, h)
          if not current_hover then return end
          if current_hover == 1 then
            hover_text = mrobbery.language[mrobberycfg.language]["hover_lsbtns"]
          elseif current_hover == 2 then
            hover_text = mrobbery.language[mrobberycfg.language]["hover_ptbtn"]
          elseif current_hover == 3 then
            hover_text = mrobbery.language[mrobberycfg.language]["hover_cctv"]
          end
          draw.DrawText(hover_text, "Trebuchet24c", w / 2, h * .1, Color(46, 134, 222,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
  end)
  function Base:OnClose()
      hook.Remove("CalcView", "MBR:CalcViewUI")
      hook.Remove("CalcView", "MBR:CalcViewUIH")
      hook.Remove("CalcView", "MBR:CalcViewCam")
  end
  function Base:Paint(w, h)
      draw.RoundedBox(0, 3, 3, w - mrobbery.f.RespX(6), h - mrobbery.f.RespY(6), Color(34, 47, 62, 255))
  end
  Base:SetAlpha(0)
  Base:AlphaTo(255, 1, .2)

  local lsbtns = vgui.Create("DButton", Base)
  lsbtns:SetSize(mrobbery.f.RespX(128), mrobbery.f.RespY(128))
  lsbtns:SetText("")
  lsbtns.Paint = function(_, w, h)
      lsbtns:SetPos(Base:GetWide() * .1, Base:GetTall() / 3)
      if lsbtns:IsHovered() then
          mrobbery.lib.DrawFilledCircle(w/2 - .75, h/2 + 1.25, w/2 - 7, 0, 360, Color(54, 67, 82, 255))
      end
      mrobbery.lib.ThicknessCircle(w/2 - 1, h/2 +1, w/2-6, 2, 0, 360, Color(87, 101, 116, 255))
      if not mrobbery.lsenabled then
          surface.SetMaterial(mrobbery.laser_icon)
          surface.SetDrawColor(149, 175, 192)
          surface.DrawTexturedRect(w / 2 - mrobbery.f.RespX(32), h / 2 - mrobbery.f.RespY(32), mrobbery.f.RespX(64), mrobbery.f.RespY(64))
      else
          surface.SetMaterial(mrobbery.laser_icon)
          surface.SetDrawColor(255, 121, 121)
          surface.DrawTexturedRect(w / 2 - mrobbery.f.RespX(32), h / 2 - mrobbery.f.RespY(32), mrobbery.f.RespX(64), mrobbery.f.RespY(64))
      end
  end
  lsbtns.DoClick = function()
      surface.PlaySound("museum_robbery/btn_light.ogg")
      net.Start("MRB:UI:BtnSec")
      net.WriteInt(2, 3)
      net.SendToServer()
  end
  function lsbtns:OnCursorEntered()
    current_hover = 1
  end
  function lsbtns:OnCursorExited()
    current_hover = nil
  end

  local ptbtn = vgui.Create("DButton", Base)
  ptbtn:SetSize(mrobbery.f.RespX(128), mrobbery.f.RespY(128))
  ptbtn:SetText("")
  ptbtn.Paint = function(_, w, h)
      ptbtn:SetPos(Base:GetWide() /2 - (ptbtn:GetWide() / 2), Base:GetTall() / 3)
      if ptbtn:IsHovered() then
          mrobbery.lib.DrawFilledCircle(w/2 - .75, h/2 + 1.25, w/2 - 7, 0, 360, Color(54, 67, 82, 255))
      end

      mrobbery.lib.ThicknessCircle(w/2 - 1, h/2 +1, w/2-6, 2, 0, 360, Color(87, 101, 116, 255))
      if not mrobbery.pgsecured then
          draw.SimpleText(utf8.char(0xf03e), "icon2", w / 2, h / 2 + 2, Color(149, 175, 192), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      else
          draw.SimpleText(utf8.char(0xf03e), "icon2", w / 2, h / 2 + 2, Color(255, 121, 121), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
  end
  ptbtn.DoClick = function()
      surface.PlaySound("museum_robbery/btn_light.ogg")
      net.Start("MRB:UI:BtnSec")
      net.WriteInt(1, 3)
      net.SendToServer()
  end
  function ptbtn:OnCursorEntered()
    current_hover = 2
  end
  function ptbtn:OnCursorExited()
    current_hover = nil
  end

  local cambtn = vgui.Create("DButton", Base)
  cambtn:SetSize(mrobbery.f.RespX(128), mrobbery.f.RespY(128))
  cambtn:SetText("")
  cambtn.Paint = function(_, w, h)
      cambtn:SetPos(Base:GetWide() * .9 - mrobbery.f.RespX(128), Base:GetTall() / 3)
      if cambtn:IsHovered() then
          mrobbery.lib.ThicknessCircle(w/2 - 2, h/2, w/2-6, 2, 0, 360, Color(87, 101, 116, 255))
          mrobbery.lib.DrawFilledCircle(w/2 - 2, h/2, w/2 - 7, 0, 360, Color(54, 67, 82, 255))
          draw.SimpleText(utf8.char(0xf03d), "icon2", w / 2, h / 2, Color(255, 190, 118), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      else
          mrobbery.lib.ThicknessCircle(w/2 - 2, h/2, w/2-6, 2, 0, 360, Color(87, 101, 116, 255))
          draw.SimpleText(utf8.char(0xf03d), "icon2", w / 2, h / 2, Color(255, 190, 118), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
  end
  cambtn.DoClick = function()
    Base:animclose()
    timer.Simple(.3, function()
      surface.PlaySound("museum_robbery/btn_light.ogg")
      net.Start("MRB:UI:BtnCam")
      net.SendToServer()
    end)
  end
  function cambtn:OnCursorEntered()
    current_hover = 3
  end
  function cambtn:OnCursorExited()
    current_hover = nil
  end
end)

net.Receive("MRB:UpdateSpeVar", function()
  local var = net.ReadInt(6)
  local bool = net.ReadBool()

  if var == 1 then
    mrobbery.pgsecured = bool
  elseif var == 2 then
    mrobbery.lsenabled = bool
  elseif var == 3 then
    mrobbery.cache = net.ReadTable()
  elseif var == 4 then
    LocalPlayer().ErrPerc = true
    surface.PlaySound("btn_heavy.ogg")
    timer.Simple(3, function()
      LocalPlayer().ErrPerc = false
    end)
  elseif var == 5 then
    LocalPlayer().CloseReseller = true
    timer.Simple(.2, function()
      LocalPlayer().CloseReseller = false
    end)
  elseif var == 6 then
    mrobberycfg = net.ReadTable()
  end
end)

local function SetActiveCalcViewByCam(ent) -- Function for the CCTV System
  hook.Remove("CalcView", "MBR:Calc_View_Cam")

	local ent_ang = (-ent:GetUp()):Angle()
	LocalPlayer():SetEyeAngles(ent_ang)

  hook.Add("CalcView", "MBR:Calc_View_Cam", function()
      local view = {}
      if IsValid(ent) then
        ent_ang:Forward()
          ent_ang:Up()
          view.angles = Angle(ent_ang.p, ent_ang.y, 0)
          view.origin = ent:GetPos()
          view.fov = 130
          view.drawviewer = true

          return view
      end
  end)
end

net.Receive("MRB:UI:CAM", function() -- Receive the net to display the cctv panel.
	local cameras = net.ReadTable()

	LocalPlayer().ActiveCam = 1
	SetActiveCalcViewByCam(cameras[1])

	local InterfaceCameras = vgui.Create("DFrame")
	InterfaceCameras:SetSize(ScrW(), ScrH())
	InterfaceCameras:SetDraggable(false)
  InterfaceCameras:ShowCloseButton(false)
	InterfaceCameras:MakePopup()
	InterfaceCameras:SetTitle("")
	InterfaceCameras.Paint = function(_, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(34, 47, 62, 75))
	end
	InterfaceCameras.OnClose = function()
		hook.Remove("CalcView", "MBR:Calc_View_Cam")
		LocalPlayer().ActiveCam = nil
	end

	local closebtn = vgui.Create("DButton", InterfaceCameras)
	closebtn:SetSize(mrobbery.f.RespX(64), mrobbery.f.RespY(64))
	closebtn:SetPos(InterfaceCameras:GetWide() - closebtn:GetWide(), 0)
	closebtn:SetText("")
	closebtn.Paint = function(_, w, _)
			draw.SimpleText(utf8.char(0xf057), "icon3", w / 3.5, 5.5, Color(255, 107, 107, 255))
	end
	closebtn.DoClick = function()
			surface.PlaySound("museum_robbery/btn_light.ogg")
			InterfaceCameras:Close()
	end

	local Basebtns = vgui.Create("DPanel", InterfaceCameras)
	Basebtns:SetSize(ScrW(), InterfaceCameras:GetTall() * .1)
	Basebtns:SetPos(0, InterfaceCameras:GetTall() * .9)
	Basebtns.Paint = function(_, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(34, 47, 62, 200))
	end

	for k, v in pairs(cameras) do
		if not IsValid(v) then continue end
		local btncam = vgui.Create("DButton", Basebtns)
		btncam:SetSize(Basebtns:GetWide() * .075 - mrobbery.f.RespX(15), Basebtns:GetTall() * .6)
		btncam:SetPos(btncam:GetWide() * k + k * mrobbery.f.RespX(15) - mrobbery.f.RespX(100), Basebtns:GetTall() / 2 - (btncam:GetTall() / 2))
		btncam:SetText("")
		btncam.Paint = function(_, w, h)
			if LocalPlayer().ActiveCam == k then
				draw.RoundedBox(3, 0, 0, w, h, Color(131, 149, 167))
				draw.RoundedBox(2, mrobbery.f.RespX(2), mrobbery.f.RespY(2), w - mrobbery.f.RespX(4), h - mrobbery.f.RespY(4), Color(87, 101, 116))
			else
				draw.RoundedBox(3, 0, 0, w, h, Color(200, 214, 229))
				draw.RoundedBox(2, mrobbery.f.RespX(2), mrobbery.f.RespY(2), w - mrobbery.f.RespX(4), h - mrobbery.f.RespY(4), Color(34, 47, 62))
			end
			draw.SimpleText("Camera #" .. k, "DermaDefault", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		btncam.DoClick = function()
			LocalPlayer().ActiveCam = k
			SetActiveCalcViewByCam(v)
		end
	end
end)

net.Receive("MRB:Painting", function()
  local purl = net.ReadString() or ""

  local Base = vgui.Create("DFrame")
  Base:SetSize(0, 0)
  Base:SetPos(ScrW() * .4, ScrH() * .3)
  Base:SetTitle("")
  Base:SetDraggable(false)
  Base:MakePopup()
  Base:ShowCloseButton(false)
  Base.Paint = function(_, w, h)
      draw.RoundedBox(4, 0, 0, w, h, Color(52, 73, 94))
      draw.RoundedBox(4, 0, 0, w, h * .1, Color(52, 152, 219, 255))
      draw.SimpleTextOutlined(mrobbery.language[mrobberycfg.language]["editing_ptg"], "Trebuchet24b", w / 2, h * .05, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
  end
  Base:SizeTo(ScrW() * .2, ScrH() * .3, .75, 0, -1, function()
    local exitbtn = vgui.Create("DButton", Base)
    exitbtn:SetSize(Base:GetWide() * .075, Base:GetTall() * .075)
    exitbtn:SetPos(Base:GetWide() * .925, Base:GetTall() * .025)
    exitbtn:SetText("")
    exitbtn.Paint = function(_, w, h)
        draw.SimpleText(utf8.char(0xf2f5), "icon", w / 2, h / 3, Color(231, 76, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    exitbtn.DoClick = function()
        surface.PlaySound("museum_robbery/btn_light.ogg")
        Base:Close()
    end

    local prv = vgui.Create("DHTML", Base)
    prv:SetPos(Base:GetWide() * .1, Base:GetTall() * .27)
    prv:SetSize(Base:GetWide() * .3, Base:GetTall() * .5)

    function prv:UpdateUrl(url)
      self:SetHTML([[
      <style type="text/css">
        html {
          overflow: hidden;
        }
      </style>
      <img src="https://i.imgur.com/]].. url ..[[.png" style="width:100%;height:95%;">]])
    end

    local txte = vgui.Create("DTextEntry", Base)
    txte:SetText("")
    txte:SetValue(purl)
    txte:SetDrawLanguageID(false)
    txte:SetPlaceholderText(mrobbery.language[mrobberycfg.language]["imgur_id"])
    txte:SetSize(Base:GetWide() * .4, Base:GetTall() * .15)
    txte:SetPos(Base:GetWide() * .9 - txte:GetWide(), Base:GetTall() * .275)

    local uppreview = vgui.Create("DButton", Base)
    uppreview:SetSize(Base:GetWide() * .4, Base:GetTall() * .15)
    uppreview:SetPos(Base:GetWide() * .9 - uppreview:GetWide(), Base:GetTall() * .45)
    uppreview:SetText("")
    uppreview.Paint = function(_, w, h)
      draw.RoundedBox(4, 0, 0, w, h, Color(211, 84, 0, 255))
      draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(230, 126, 34, 255))
      draw.SimpleText(mrobbery.language[mrobberycfg.language]["update_p"] or "Update Preview", "Trebuchet10", w / 2, h / 2, Color(236, 240, 241), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    uppreview.DoClick = function()
        surface.PlaySound("museum_robbery/btn_light.ogg")
        prv:UpdateUrl(txte:GetValue())
    end

    local saveconf = vgui.Create("DButton", Base)
    saveconf:SetSize(Base:GetWide() * .4, Base:GetTall() * .15)
    saveconf:SetPos(Base:GetWide() * .9 - saveconf:GetWide(), Base:GetTall() * .625)
    saveconf:SetText("")
    saveconf.Paint = function(_, w, h)
      draw.RoundedBox(4, 0, 0, w, h, Color(39, 174, 96, 255))
      draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(46, 204, 113, 255))
      draw.SimpleText(mrobbery.language[mrobberycfg.language]["save_p"] or "Save Config", "Trebuchet10", w / 2, h / 2, Color(236, 240, 241), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    saveconf.DoClick = function()
        surface.PlaySound("museum_robbery/btn_light.ogg")
        net.Start("MRB:Painting")
        net.WriteString(txte:GetValue())
        net.SendToServer()
    end

    prv:UpdateUrl(purl)
  end)
end)

-- RESELLER NET
net.Receive("MRB:RESELLER", function()
  local paintings = net.ReadTable()

  local Base = vgui.Create("DFrame")
  Base:SetSize(mrobbery.f.RespX(0), mrobbery.f.RespY(0))
  Base:MakePopup()
  Base:SetDraggable(false)
  Base:ShowCloseButton(false)
  Base:SetTitle("")
  Base:SetPos(ScrW() * .275, ScrH() * .3)
  Base:SetSize(0,0)
	Base:SizeTo(ScrW() * .45, ScrH() * .45, 1.25, 0, -1, function()
		local dslider = vgui.Create("mrslider", Base)
		dslider:SetSize(Base:GetWide() * 1.05,  Base:GetTall() * .5)
		dslider:SetPos(-Base:GetWide() * .2425, Base:GetTall() * .4)
		dslider:SetMin(0)
		dslider:SetMax(mrobberycfg.pricepp)
		dslider:SetValue(mrobberycfg.pricepp / 2)

		local dpanel = vgui.Create("DPanel", Base)
		dpanel:SetSize(Base:GetWide(),  Base:GetTall() * .2)
		dpanel:SetPos(0, Base:GetTall() * .35)
		dpanel.Paint = function(s, w, h)
			draw.SimpleText(mrobbery.language[mrobberycfg.language]["reseller_txt"] or "For reseller", "scdb", w * .01, 0, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.SimpleText(math.Round(dslider:GetMax() * #paintings - (dslider:GetSlideX() * dslider:GetMax() * (#paintings)), 1) .. "$", "scdb", w * .01, h * .3, Color(255, 159, 67), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.SimpleText(100 - math.Round(100 * dslider:GetSlideX()) .. "%", "scdb", w * .01, h * .6, Color(255, 159, 67), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

			draw.SimpleText(mrobbery.language[mrobberycfg.language]["you_txt"] or "For you", "scdb", w * .99, 0, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
			draw.SimpleText(math.Round(dslider:GetMax() * #paintings * dslider:GetSlideX(), 1).. "$", "scdb", w * .99, h * .3, Color(16, 172, 132), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
			draw.SimpleText(math.Round(100 * dslider:GetSlideX()) .. "%", "scdb", w * .99, h * .6, Color(16, 172, 132), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)

		end

		local clbtn = vgui.Create("DButton", Base)
		clbtn:SetSize(Base:GetWide() * .1,  Base:GetTall() * .1)
		clbtn:SetText("")
		clbtn:SetPos(Base:GetWide() * 0.925, 0)
		clbtn.Paint = function(s, w, h)
			draw.SimpleText(utf8.char(0xf057), "icon", w / 2, h / 2, Color(255, 86, 84), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		clbtn.DoClick = function()
			Base:SizeTo(0, 0, 1, 0, -1, function()
				Base:Close()
			end)
		end

		local send = vgui.Create("DButton", Base)
    send:SetSize(Base:GetWide() * .3, Base:GetTall() * .15)
    send:SetPos(Base:GetWide() * .35, Base:GetTall() * .825)
    send:SetText("")
    send.Paint = function(_, w, h)
      draw.RoundedBox(4, 0, 0, w, h, Color(39, 174, 96, 255))
      draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(46, 204, 113, 255))
      draw.SimpleText(mrobbery.language[mrobberycfg.language]["r_valid_"], "Trebuchet10", w / 2, h / 2, Color(236, 240, 241), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    send.DoClick = function()
        surface.PlaySound("museum_robbery/btn_light.ogg")
        net.Start("MRB:RESELLER")
        net.WriteFloat(dslider:GetSlideX())
        net.SendToServer()
    end
	end)
  function Base:Paint(w, h)
    draw.RoundedBox(4, 3, 3, w - mrobbery.f.RespX(6), h - mrobbery.f.RespY(6), Color(34, 47, 62, 255))

    // Slider things
    draw.RoundedBox(5, w * .215, h * .62, 6 * mrobbery.f.RespX(80), h * .02, Color(149, 165, 166))
    for i = 1, 7 do
      if i == 1 or i == 7 then
        draw.RoundedBox(5, w * .12 + i *  mrobbery.f.RespX(80), h * .5, ScrW() * .01, h * .25, Color(149, 165, 166))
      else
        draw.RoundedBox(5, w * .12 + i *  mrobbery.f.RespX(80), h * .525, ScrW() * .004, h * .2, Color(149, 165, 166))
      end
    end

		if LocalPlayer().ErrPerc then
			draw.SimpleText(mrobbery.language[mrobberycfg.language]["err_prc-npc"], "Trebuchet24c", w / 2, h * .15, Color(255, 107, 107), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

    draw.SimpleText(mrobbery.language[mrobberycfg.language]["acthav_txt"]:format(#paintings) or "nil", "Trebuchet24b", w / 2, h * .05, Color(84, 160, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(mrobbery.language[mrobberycfg.language]["npc_p_txt"]:format(mrobberycfg.percent) or "nil", "Trebuchet24b", w / 2, h * .1, Color(84, 160, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
	function Base:Think()
		if LocalPlayer().CloseReseller then
			Base:SizeTo(0, 0, 1, 0, -1, function()
				Base:Close()
			end)
		end
	end
end)

--- OFFER PART
local function DisplayPopup(notif)
    if not istable(notif) then return end

    local curhovered = nil
    local tpsdp = notif.starttime

    local Base = vgui.Create("DFrame")
    Base:MakePopup()
    Base:SetSize(ScrW() * .3, ScrH() * .475)
    Base:SetTitle("")
    Base:ShowCloseButton(false)
    Base:SetDraggable(false)
    Base:Center()
    Base.timerexp = 0

    Base.Paint = function(_, w, h)
      draw.RoundedBoxEx(20, 0, h * .1, w, h - h*.1, Color(34, 47, 62), false, false, true, true) -- Background
      draw.RoundedBoxEx(20, 0, 0, w, h * .1, Color(84, 160, 255), true, true) -- Header

      draw.SimpleText("You received an offer.","Trebuchet24b", w * .375, h * .1 / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      if Base.timerexp <= 5 then
        draw.SimpleText("Expires in: " .. tostring(math.Round(Base.timerexp)) .. "s.","Trebuchet24b", w * .7, h * .1 / 2, Color(255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if Base.timerexp <= 0 then
          Base:Close()
        end
      else
        draw.SimpleText("Expires in: " .. tostring(math.Round(Base.timerexp)) .. "s.","Trebuchet24b", w * .71, h * .1 / 2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end

      draw.SimpleText(string.format("\"%s\" wants to have", notif.entname or "nil"), "Trebuchet24b", w / 2, h * .175, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText((notif.pts or "0") .. " of your paintings.", "Trebuchet24b", w / 2, h * .225, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText(string.format("The museum offers %s in exchange of", DarkRP.formatMoney(notif.price or 0)), "Trebuchet24b", w / 2, h * .275, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("your paintings.", "Trebuchet24b", w / 2, h * .325, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

      if curhovered == "no" then
        draw.SimpleText("Decline","Trebuchet24b", w / 2, h * .95, Color(255, 107, 107), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      elseif curhovered == "yes" then
        draw.SimpleText("Accept","Trebuchet24b", w / 2, h * .95, Color(29, 209, 161), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
    end

    local Scroll = vgui.Create( "DScrollPanel", Base )
    Scroll:SetPos(Base:GetWide() * .075, Base:GetTall() * .425)
    Scroll:SetSize(Base:GetWide() * .85, Base:GetTall() * .26)

    local List = vgui.Create( "DIconLayout", Scroll )
    List:Dock( FILL )
    List:SetSpaceY( 10 )
    List:SetSpaceX( 10 )

    for k, v in pairs(notif.paintings) do
      local bmat = Material(v:GetSubMaterial(1)):GetTexture("$basetexture"):GetName() -- This is to fix an issue with ambient lightning
      local mat = Material(bmat .. ".jpg")

      if mat:IsError() then continue end -- We don't want to display a painting if she is in error.

      local ListItem = List:Add("DPanel")
      ListItem:SetSize(Base:GetWide() * .15, Base:GetTall() * .25)
      ListItem.Paint = function(s, w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(0, 0, w, h)
      end
    end

    local yesbtn = vgui.Create("DButton", Base)
    yesbtn:SetSize(Base:GetWide() * .15, Base:GetTall() * .2)
    yesbtn:SetPos(Base:GetWide() * .3, Base:GetTall() * .7)
    yesbtn:SetText("")
    yesbtn.Paint = function(s, w, h)
        draw.SimpleText(utf8.char(0xf00c), "iconspopup", w / 2, h / 2, Color(29, 209, 161), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    yesbtn.DoClick = function()
        net.Start("MRB:Offer")
        net.SendToServer()
        Base:Close()

        surface.PlaySound("museum_robbery/btn_light.ogg")
    end

    local nobtn = vgui.Create("DButton", Base)
    nobtn:SetSize(Base:GetWide() * .15, Base:GetTall() * .2)
    nobtn:SetPos(Base:GetWide() * .575, Base:GetTall() * .7)
    nobtn:SetText("")
    nobtn.Paint = function(s, w, h)
        draw.SimpleText(utf8.char(0xf00d), "iconspopup", w / 2, h / 2, Color(255, 107, 107, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    nobtn.DoClick = function()
        Base:Close()
        surface.PlaySound("museum_robbery/btn_light.ogg")
    end

    function Base:Think()
      if nobtn:IsHovered() then
        curhovered = "no"
      elseif yesbtn:IsHovered() then
        curhovered = "yes"
      else
        curhovered = nil
      end
      Base.timerexp = mrobberycfg.offertime - (math.Clamp((CurTime() - tpsdp) / (CurTime() + mrobberycfg.offertime - CurTime()), 0, 1) * mrobberycfg.offertime)
    end
end

net.Receive("MRB:Offer", function()

  DisplayPopup(net.ReadTable())
end)
