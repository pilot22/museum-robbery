AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

mrobbery.laser_alarm = false

function ENT:Initialize()
	self:SetUseType(SIMPLE_USE)
	self:SetModel("models/props/sycreations/laser/laser.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	if not mrobbery.lsenabled then
		self:Setlaserstate(false)
	else
		self:Setlaserstate(true)
	end

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	mrobbery.entities.laser[#mrobbery.entities.laser + 1] = self
end

function ENT:Think()
	if self:Getlaserstate() then
		if IsValid(self) then
			local trace = util.TraceLine({
					start = self:GetPos(),
					endpos = self:GetPos() + self:GetAngles():Forward() * 20000,
					filter = function(ent) if ent ~= self then return true end end
			})
			local traceent = trace.Entity
			if IsValid(traceent) and traceent:IsPlayer() and team.GetName(traceent:Team()) ~= mrobberycfg.teammu and not mrobbery.laser_alarm then
				if #team.GetPlayers(TEAM_MUSEUM) >= mrobberycfg.minmuseumanag then
					if mrobberycfg.wantedde then
						traceent:wanted(traceent, mrobbery.language[mrobberycfg.language]["museum_robbery"], 120)
					end
					mrobbery.f.logging(ply, mrobbery.language[mrobberycfg.language]["laser_detect"])

					mrobbery.laser_alarm = true

					for _,v in pairs(mrobbery.entities.alarms) do
						if IsValid(v) then
							v:EmitSound("museum_robbery/alarm_mr.ogg")
						end
					end
					timer.Simple(32.7, function()
						mrobbery.laser_alarm = false
					end)
				end
			end
		end
	end
end

function ENT:OnRemove()
   for k,v in pairs(mrobbery.entities.laser) do
		 if v == self then
			 mrobbery.entities.laser[k] = nil
		 end
	 end
end
