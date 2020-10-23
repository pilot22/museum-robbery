AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/BriefCase001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(250)
	if not self:IsOnGround() then
		self:SetPos(self:GetPos() + Vector(0,0,50))
	end
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Paintings = {}
end

function ENT:AcceptInput(it, _, cal)
	if it == "Use" and IsValid(cal) and cal:IsPlayer() and cal:Alive() and IsValid(cal:GetEyeTrace().Entity) and cal:GetEyeTrace().Entity == self then
		if (team.GetName(cal:Team()) ~= mrobberycfg.teammu) then
			if (#mrobbery.f.GetPaintings(cal) + #self.Paintings <= mrobberycfg.maxcarrypaintings) then

				mrobbery.f.AddPaintingsByTable(cal, self.Paintings)
				mrobbery.f.logging(cal, mrobbery.language[mrobberycfg.language]["tk_mal_msg"])

				cal:SetNWBool("mrb_carrying", true)
		    self:Remove()
			else
				DarkRP.notify(cal, 1, 5, mrobbery.language[mrobberycfg.language]["max_paintings_malette"])
			end
		else
			DarkRP.notify(cal, 1, 5, mrobbery.language[mrobberycfg.language]["bad_job"])
		end
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() - dmg:GetDamage() < 0 then
		self:Remove()
	end
end
