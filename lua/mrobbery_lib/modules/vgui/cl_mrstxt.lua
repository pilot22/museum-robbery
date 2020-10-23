local PANEL = {}

function PANEL:Init()
  self.txt = ""
  self.color = color_white
  self.font = "Trebuchet24b"
end

function PANEL:Paint(_, h)
  draw.SimpleText(self.txt, self.font, 0, h/3, self.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:SetColor(col)
  if not IsColor(col) then return end
  self.color = col
end

function PANEL:SetTxt(text)
  if not isstring(text) then return end
  self.txt = text
end

function PANEL:SetFont(font)
  if not isstring(font) then return end
  self.font = font
end

derma.DefineControl("mrstxt", "Custom Simpletext VGUI in MRLib.", PANEL, "DPanel")
