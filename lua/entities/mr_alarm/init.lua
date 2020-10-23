AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_wasteland/speakercluster01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(SIMPLE_USE)
  mrobbery.entities.alarms[#mrobbery.entities.alarms + 1] = self
end

function ENT:OnRemove()
   for k,v in pairs(mrobbery.entities.alarms) do
		 if v == self then
			 mrobbery.entities.alarms[k] = nil
		 end
	 end
end
