include("shared.lua")

local lasermat = Material("cable/redlaser")

function ENT:Draw()
  self:DrawModel()
end

hook.Add("PostDrawTranslucentRenderables", "ResetBuffer", function()
    for _, v in pairs(ents.FindByClass('mr_laser')) do
      if v:Getlaserstate() then
        if IsValid(v) then
          local trace = util.TraceLine({
              start = v:GetPos(),
              endpos = v:GetPos() + v:GetAngles():Forward() * 20000,
              filter = function(ent) if ent ~= v then return true end end
          })
          local Vector1 = v:GetPos()
          local Vector2 = trace.HitPos
          render.SetMaterial(lasermat)
          render.DrawBeam(Vector1, Vector2, 5, 1, 1, Color(255, 255, 255, 255))
        end
      end
    end
end)
