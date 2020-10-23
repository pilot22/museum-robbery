include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if mrobberycfg.reseller_nameover then
		cam.Start3D2D(self:GetPos() + self:GetUp() * 75 + self:GetRight() + self:GetForward(), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.2)
			draw.SimpleText(mrobberycfg.reseller_name or "nil", "scdb", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end
