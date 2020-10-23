ENT.Base 			= "base_anim"
ENT.Type 			= "anim"

ENT.PrintName		= "Malette"
ENT.Author			= "Pilot2"
ENT.Category		= "Museum robbery"

ENT.Spawnable 		= false

function ENT:SetupDataTables()
  self:NetworkVar( "Int", 0, "mrb_mpaintings" )
end
