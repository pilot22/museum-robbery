AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/blackghost/blackghost_camera_pilot.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(SIMPLE_USE)
  mrobbery.entities.cameras[#mrobbery.entities.cameras + 1] = self
end

function ENT:OnRemove()
   for k,v in pairs(mrobbery.entities.cameras) do
		 if v == self then
			 mrobbery.entities.cameras[k] = nil
		 end
	 end
end

net.Receive("MRB:UI:BtnCam",function(_,ply)
	if not ply:IsValid() or not ply:IsPlayer() then return end

	local ent = mrobbery.f.checkgoodent(ply, "mr_computer")

	if not IsValid(ent) or ent:GetClass() ~= "mr_computer" then return end

	if (team.GetName(ply:Team()) == mrobberycfg.teammu) or ent:Getishacked() then
		if #mrobbery.entities.cameras == 0 then DarkRP.notify(ply, 1, 3, mrobbery.language[mrobberycfg.language]["no_cctv"]) return end

		net.Start("MRB:UI:CAM")
		net.WriteTable(mrobbery.entities.cameras)
		net.Send(ply)

	end
end)
