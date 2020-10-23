
local malettemodel = ClientsideModel("models/props_c17/BriefCase001a.mdl")
malettemodel:SetNoDraw(true)

hook.Add("PostPlayerDraw", "MRB:Draw_Malette_OnPlayer", function(ply)
    if ply:IsValid() and ply:GetNWBool("mrb_carrying") then
      if not ply:Alive() then return end
      local base = ply:LookupBone("ValveBiped.Bip01_Spine")

      if base then
        local pos, ang = ply:GetBonePosition(base)

        if pos and pos ~= ply:GetPos() then
          ang:RotateAroundAxis(ang:Right(), 80)
          ang:RotateAroundAxis(ang:Right(), -20)
          ang:RotateAroundAxis(ang:Forward(), 180)
          ang:Normalize()
          malettemodel:SetModelScale(0.85, 0)
          malettemodel:SetPos(pos + ang:Up() * 6 + ang:Forward() * 5 - ang:Right() * 6)
          malettemodel:SetAngles(ang)
        end
      end
      malettemodel:SetupBones()
      malettemodel:DrawModel()
    end
end)
