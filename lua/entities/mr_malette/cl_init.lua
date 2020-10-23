include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	local paintings = self:Getmrb_mpaintings()
	if paintings >= 1 then
		cam.Start3D2D(self:GetPos() + self:GetUp() * 15, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.15)
			if not (paintings > 1) then
				draw.SimpleText(tostring(paintings) .. " "  .. mrobbery.language[mrobberycfg.language]["painting"], "scdb", -1, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(tostring(paintings) .. " "  .. mrobbery.language[mrobberycfg.language]["paintings"], "scdb", -1, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()
	end
end
