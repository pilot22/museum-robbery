local PANEL = {}

function PANEL:Init()
  --
end

function PANEL:Paint(w,h)
  if self.state then
		draw.RoundedBox(4, 0, 0, w, h, Color(29, 209, 161, 255))
		draw.RoundedBox(6, w *.8, 0, w * .1, h, Color(200, 214, 229, 255))
  else
		draw.RoundedBox(4, 0, 0, w, h, Color(131, 149, 167, 255))
		draw.RoundedBox(6, 0, 0, w * .1, h, Color(200, 214, 229, 255))
  end
end

function PANEL:UpdateState()
  if self.state then
    self.state = false
  else
    self.state = true
  end
end

function PANEL:SetState(bool)
  if not isbool(bool) then return end
  self.state = bool
end

function PANEL:GetState()
  return self.state or false
end

derma.DefineControl("mrbtn", "Custom button for config created in MRLib.", PANEL, "DButton")
