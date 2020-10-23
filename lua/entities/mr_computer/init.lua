AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_office/computer.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(SIMPLE_USE)
end

function ENT:AcceptInput(it, _, cal)
	if it == "Use" and IsValid(cal) and cal:IsPlayer() and cal:Alive() and IsValid(cal:GetEyeTrace().Entity) and cal:GetEyeTrace().Entity:GetClass() == "mr_computer" then
		if team.GetName(cal:Team()) == mrobberycfg.teammu or self:Getishacked() then
			net.Start("MRB:UI:PC")
			net.WriteEntity(self)
			net.WriteBool(true)
			net.WriteBool(true)
			net.Send(cal)
		elseif mrobbery.f.plyIsRobber(cal) then
			if #team.GetPlayers(TEAM_MUSEUM) >= mrobberycfg.minmuseumanag then
				self:SetStartHackT(0)

				net.Start("MRB:UI:PC:HACK")
				net.WriteEntity(self)
				net.Send(cal)
			else
				DarkRP.notify(cal, 1, 3, string.format(mrobbery.language[mrobberycfg.language]["not_enough"], mrobberycfg.teammu))
			end
		else
			DarkRP.notify(cal, 1, 3, mrobbery.language[mrobberycfg.language]["bad_job"])
		end
	end
end

net.Receive("MRB:UI:HACK:Start", function(_, ply)
	if #team.GetPlayers(TEAM_MUSEUM) >= mrobberycfg.minmuseumanag then
		local ent = mrobbery.f.checkgoodent(ply, "mr_computer")
		ent:SetStartHackT(CurTime() + mrobberycfg.hacktime)

		if not mrobbery.f.plyIsRobber(ply) then return end

		timer.Create("MRB:HackBy" .. ply:SteamID(), mrobberycfg.hacktime + .1, 1, function()
			if not IsValid(ent) then return end

			ent:Setishacked(true)

			if mrobberycfg.wantedha then
				ply:wanted(ply, mrobbery.language[mrobberycfg.language]["museum_robbery"], 120)
			end

			timer.Simple(3.1, function()
				net.Start("MRB:UI:PC")
				net.WriteEntity(ent)
				net.WriteBool(false)
				net.WriteBool(false)
				net.Send(ply)
			end)

			timer.Simple(mrobberycfg.hackedtime + 3.1, function()
				ent:Setishacked(false)
			end)
		end)
		mrobbery.f.logging(ply, mrobbery.language[mrobberycfg.language]["hack_log_msg"])
	else
		DarkRP.notify(cal, 1, 3, string.format(mrobbery.language[mrobberycfg.language]["not_enough"], mrobberycfg.teammu))
	end

end)

net.Receive("MRB:UI:HACK:Cancel", function(_, ply)
	local ent = mrobbery.f.checkgoodent(ply, "mr_computer")

	if not IsValid(ent) then return end
	if timer.Exists("MRB:HackBy" .. ply:SteamID()) then
		timer.Remove("MRB:HackBy" .. ply:SteamID())
	end
end)

net.Receive("MRB:UI:BtnSec",function(_, ply)
	if not ply:IsValid() or not ply:IsPlayer() then return end

	local ent = mrobbery.f.checkgoodent(ply, "mr_computer")
	if not IsValid(ent) or ent:GetClass() ~= "mr_computer" then return end
	local tosecure = net.ReadInt(3)

	if (team.GetName(ply:Team()) == mrobberycfg.teammu) then
		mrobbery.f.Secure(tosecure, ent)
	end

	if ent:Getishacked() and mrobbery.f.plyIsRobber(ply) then
		if #team.GetPlayers(TEAM_MUSEUM) >= mrobberycfg.minmuseumanag then
			mrobbery.f.Secure(tosecure, ent)
		else
			DarkRP.notify(cal, 1, 3, string.format(mrobbery.language[mrobberycfg.language]["not_enough"], mrobberycfg.teammu))
		end
	end
end)
