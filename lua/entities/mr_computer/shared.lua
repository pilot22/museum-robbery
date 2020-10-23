ENT.Base 			    = "base_anim"
ENT.Type 		     	= "anim"

ENT.PrintName		  = "Computer"
ENT.Author			  = "Pilot2"
ENT.Category		  = "Museum robbery"

ENT.Spawnable 		= true
ENT.AdminOnly 		= true


function ENT:SetupDataTables()
  self:NetworkVar( "Bool", 0, "ishacked" )
  self:NetworkVar( "Float", 0, "StartHackT" )

end
