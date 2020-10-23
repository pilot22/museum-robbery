AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(mrobberycfg.reseller_skin)
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:SetUseType(SIMPLE_USE)
    self:SetUseType(SIMPLE_USE)
    self:SetMaxYawSpeed(90)
end

function ENT:AcceptInput(it, _, cal)
	if it == "Use" and IsValid(cal) and cal:IsPlayer() and cal:Alive() and IsValid(cal:GetEyeTrace().Entity) and cal:GetEyeTrace().Entity == self then
		if (team.GetName(cal:Team()) ~= mrobberycfg.teammu) then
			if #mrobbery.f.GetPaintings(cal) >= 1 then
				net.Start("MRB:RESELLER")
        net.WriteTable(mrobbery.f.GetPaintings(cal))
				net.Send(cal)
			else
				DarkRP.notify(cal, 1, 5, mrobbery.language[mrobberycfg.language]["no_paintings"])
			end
		else
			DarkRP.notify(cal, 1, 5, mrobbery.language[mrobberycfg.language]["bad_job"])
		end
	end
end

net.Receive("MRB:RESELLER", function(_, ply)
    local slide = net.ReadFloat()
    local max = mrobberycfg.pricepp -- The minimum percentage defined in the configuration
    local paintings = ply.paintings or {}
    local min_perc = mrobberycfg.percent -- The minimum percentage defined in the configuration

    if not (slide >= 0) or slide > 1 or #paintings == 0 or team.GetName(ply:Team()) == mrobberycfg.teammu then return end -- Security

    local resam = math.Round(max * #paintings - (slide * max * (#paintings)), 1) -- The amount for the reseller
    local resper = 100 - math.Round(100 * slide) -- The percentage for the reseller

    local plyam = math.Round(max * #paintings * slide, 1) -- The amount for the player
    local plyper = math.Round(100 * slide)-- The percentage for the player

    if plyam < 0 then return end -- Security

    if (plyam > (#paintings * max)) then return end -- Security

    if resper < min_perc or (resper+plyper > 100) or (resper+plyper < 0) then
      net.Start("MRB:UpdateSpeVar") -- set a variable clientside to display the error text on the Reseller UI
      net.WriteInt(4, 6)
      net.WriteBool(true)
      net.Send(ply)
      return
    end

    net.Start("MRB:UpdateSpeVar") -- set a variable clientside to trigger the closing of the Reseller UI
    net.WriteInt(5, 6)
    net.WriteBool(true)
    net.Send(ply)

    timer.Simple(1.1, function() -- Closing the Reseller UI before giving his prize.
      if not IsValid(ply) then return end -- just a last check :p

      mrobbery.f.logging(ply, string.format(mrobbery.language[mrobberycfg.language]["resel_log"], #paintings, DarkRP.formatMoney(plyam))) -- Log the resell

      ply:SetNWBool("mrb_carrying", false) -- Disable the
      mrobbery.f.ClearPaintings(ply)

      DarkRP.notify(ply, 0, 5, string.format(mrobbery.language[mrobberycfg.language]["notif_resell"], DarkRP.formatMoney(plyam)))
      ply:addMoney(plyam)
    end)
end)
