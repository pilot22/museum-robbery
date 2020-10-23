include('shared.lua')

function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos()
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    if LocalPlayer():GetPos():Distance(self:GetPos()) < 500 then
        cam.Start3D2D(pos + ang:Right() * -25 + ang:Up() * 0.3 + ang:Forward() * -11, ang, 0.1)
          draw.RoundedBox(0, 0, 0, 210, 50, Color(41, 128, 185)) -- Header
          draw.RoundedBox(0, 0, 130, 210, 35, Color(34, 47, 62)) -- Footer

          draw.SimpleText(mrobbery.language[mrobberycfg.language]["computer_3d2d"], "scdb", 117, 25, Color(200, 214, 229,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Title of the computer
          draw.SimpleText(utf8.char(0xf3ed), "icon", 15, 25, Color(200, 214, 229,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Icon in the left corner of the footer
          draw.SimpleText(mrobbery.language[mrobberycfg.language]["press_e"], "PC_3d2D_a", 104, 145, Color(200, 214, 229,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- Press E text
        cam.End3D2D()
    end
end
