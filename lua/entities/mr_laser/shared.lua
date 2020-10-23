ENT.Type        = "anim"
ENT.Base        = "base_gmodentity"

ENT.PrintName		= "Laser"
ENT.Author			= "Pilot2"
ENT.Category		= "Museum robbery"

ENT.Spawnable   = true
ENT.AdminOnly 	= true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
  self:NetworkVar( "Bool", 0, "laserstate" )
end
