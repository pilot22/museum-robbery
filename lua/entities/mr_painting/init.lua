AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetUseType(SIMPLE_USE)
	self:SetSkin(0)
	self:SetModel("models/props/museum_robbery/sycreations/security_frame/ts.mdl")
	self:SetSubMaterial(1, "")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
	self.prev = ""
	self.robber = nil
	mrobbery.entities.paintings[#mrobbery.entities.paintings + 1] = self
	self:Close_Open()
end

function ENT:CancelSteal(ply)
	net.Start("MRB:Stealing")
  net.WriteBool(false)
	net.WriteFloat(0)
	net.WriteFloat(0)
	net.Send(ply)

	if timer.Exists("PaintingStealingBy" .. ply:SteamID()) then
		self.robber = nil
		timer.Remove("PaintingStealingBy" .. ply:SteamID())
	end
end

function ENT:Close_Open()
	if not mrobbery.pgsecured then
		self:SetSubMaterial(2, "museum_robbery/sycreations/security_frame/ts_shutter_open")
	else
		self:SetSubMaterial(2, "museum_robbery/sycreations/security_frame/ts_shutter_closed")
	end
end

function ENT:AcceptInput(it, _, cal)
	if it == "Use" and IsValid(cal) and cal:IsPlayer() and cal:Alive() and IsValid(cal:GetEyeTrace().Entity) and cal:GetEyeTrace().Entity == self and self:GetPos():Distance(cal:GetPos()) <= mrobberycfg.maxdisttosteal then
		if self:Getoffered() == true then cal:ChatPrint(mrobbery.language[mrobberycfg.language]["pt_offered"]) return end
		if mrobbery.f.plyIsRobber(cal) then
			if not mrobbery.pgsecured then
				if self:Getimgururl() == "" then DarkRP.notify(cal, 0, 3, mrobbery.language[mrobberycfg.language]["nts_pt"]) return end
				if #team.GetPlayers(TEAM_MUSEUM) >= mrobberycfg.minmuseumanag then
					if #mrobbery.f.GetPaintings(cal) + 1 <= mrobberycfg.maxcarrypaintings then
						if timer.Exists("PaintingStealingBy" .. cal:SteamID()) then return end
						if not self:Getstolen() and not self.robber then
							self.robber = cal
							net.Start("MRB:Stealing")
							net.WriteBool(true)
							net.WriteFloat(CurTime())
							net.WriteFloat(mrobberycfg.timetosteal)
							net.Send(cal)

							timer.Create("PaintingStealingBy" .. cal:SteamID(), mrobberycfg.timetosteal, 1, function()
								mrobbery.f.SmartCacheByPainting(self)
								self:SetImgurID("")
								self:Setimgururl("")
								self:CancelSteal(cal)
								self:Setstolen(true)
								self.prev = ""

								self:SetSubMaterial(1, "models/props_pipes/GutterMetal01a")
								cal:SetNWBool("mrb_carrying", true)

								if mrobberycfg.wantedst then
									cal:wanted(cal, mrobbery.language[mrobberycfg.language]["museum_robbery"], 120)
								end

								mrobbery.f.AddPaintingsByEntity(cal, self)
								mrobbery.f.logging(cal, mrobbery.language[mrobberycfg.language]["stoled_pt_msg"])
							end)
						else
							self:CancelSteal(cal)
							DarkRP.notify(cal, 1, 3, mrobbery.language[mrobberycfg.language]["already_stolen"])
						end
					else
						DarkRP.notify(cal, 1, 3, mrobbery.language[mrobberycfg.language]["max_paintings"])
					end
				else
					DarkRP.notify(cal, 0, 3, string.format(mrobbery.language[mrobberycfg.language]["not_enough"], mrobberycfg.teammu))
				end
			else
				DarkRP.notify(cal, 1, 3, mrobbery.language[mrobberycfg.language]["secured"])
			end
		elseif team.GetName(cal:Team()) == mrobberycfg.teammu then
			if not self:Getstolen() and not self.robber then
				if mrobbery.pgsecured then DarkRP.notify(cal, 1, 3, mrobbery.language[mrobberycfg.language]["secured"]) return end
				cal.ptediting = self

			  net.Start("MRB:Painting")
				net.WriteString(self:GetImgurID() or "")
				net.Send(cal)
			else
				DarkRP.notify(cal, 1, 3, mrobbery.language[mrobberycfg.language]["already_stolen"])
			end
		else
			DarkRP.notify(cal, 1, 3, mrobbery.language[mrobberycfg.language]["bad_job"])
		end
	end
end

function ENT:OnRemove()
	mrobbery.f.SmartCacheByPainting(self)
	self.prev = ""
	self:SetImgurID("")
   for k, v in pairs(mrobbery.entities.paintings) do
		 if v == self then
			 mrobbery.entities.paintings[k] = nil
			 break
		 end
	 end
end

function ENT:Think()
	local ply = self.robber
	if IsValid(ply) and ply:IsPlayer() then
		if ply:GetEyeTrace().Entity ~= self or self:GetPos():Distance(ply:GetPos()) >= mrobberycfg.maxdisttosteal then
			self:CancelSteal(ply)
			return
		end
	end
end
