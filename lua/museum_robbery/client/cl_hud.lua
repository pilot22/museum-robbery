-- Do not touch this file !

function mrobbery.f.RespX(x)
    return x / 1920 * ScrW()
end

function mrobbery.f.RespY(y)
    return y / 1080 * ScrH()
end
surface.CreateFont("iconspopup", {
    font = "Font Awesome 5 Free Solid",
    antialias = true,
    extended = true,
    size = ScreenScale(32)
})
surface.CreateFont("Trebuchet24b", {
  font = "Trebuchet24",
  antialias = true,
  extended = true,
	weight = 550,
  size = ScreenScale(9)
})
surface.CreateFont("Trebuchet10", {
  font = "Trebuchet24",
  antialias = true,
  extended = true,
	weight = 600,
  size = ScreenScale(6)
})
surface.CreateFont("scdb", {
    font = "ScoreboardDefaultTitle",
    antialias = true,
    size = ScreenScale(11),
    weight = 600
})
surface.CreateFont("PC_3d2D_a", {
    font = "ScoreboardDefault",
    antialias = true,
    size = ScreenScale(4.5),
    weight = 800
})
surface.CreateFont("PC_3d2D_b", {
    font = "ScoreboardDefault",
    antialias = true,
    size = ScreenScale(25)
})
surface.CreateFont("Trebuchet24c", {
  font = "Trebuchet24",
  antialias = true,
  extended = true,
	weight = 550,
  size = ScreenScale(8)
})
surface.CreateFont("icon", {
    font = "Font Awesome 5 Free Solid",
    antialias = true,
    extended = true,
    size = ScreenScale(9)
})
surface.CreateFont("icon2", {
    font = "Font Awesome 5 Free Solid",
    antialias = true,
    extended = true,
    size = ScreenScale(24)
})
surface.CreateFont("icon3", {
    font = "Font Awesome 5 Free Solid",
    antialias = true,
    extended = true,
    size = ScreenScale(14)
})

net.Receive("MRB:Stealing", function()
	LocalPlayer().Stealing = net.ReadBool()
	LocalPlayer().SStarted = net.ReadFloat()
	LocalPlayer().STime = net.ReadFloat()
end)

hook.Add("HUDPaint", "MRB_DrawHudThings", function()
  local paintings = LocalPlayer():GetNWInt("mrb_paintings") or 0

  if mrobbery.isnpcresell then return end

  if LocalPlayer().Stealing then
    local perc = math.Clamp((CurTime() - LocalPlayer().SStarted) / LocalPlayer().STime, 0, 1)

		mrobbery.lib.ThicknessCircle(ScrW()/2, ScrH()/2, 40, 10, 90, perc * 360 + 90, Color(255, 255, 255))
  end

  if paintings > 0 then
    draw.SimpleTextOutlined(string.format(mrobbery.language[mrobberycfg.language]["carrying_paintings"], paintings), "Trebuchet24b", ScrW() / 2, ScrH() * .025, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 255))
		draw.SimpleTextOutlined(string.format(mrobbery.language[mrobberycfg.language]["drop_painting"], string.upper(input.GetKeyName(mrobberycfg.keytodrop))), "Trebuchet24b", ScrW() / 2, ScrH() * .05, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 255))
	end
end)
