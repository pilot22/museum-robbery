-- Do not touch this file !

hook.Add("PlayerInitialSpawn","MRB:Hooks:InitializePlayer", function(ply, _)
  if IsValid(ply) and ply:IsPlayer() then
    mrobbery.f.BroadcastCFG(ply)
    mrobbery.f.ClearPaintings(ply)
    mrobbery.f.BroadcastCache(ply)

    for k, v in pairs(mrobbery.cachetodownload) do
      if v == true then
      	net.Start("MRB:DLMAT")
      	net.WriteString(tostring(k))
      	net.Send(ply)
      end
    end
  end
end)

hook.Add("PlayerSpawn", "MRB:Hooks:Offer:onSpawn", function(ply)
  if ply:IsPlayer() then
    if team.GetName(ply:Team()) == mrobberycfg.teammu then
      mrobbery.offers:Thinking(ply)
    end
  end
end)

hook.Add("PlayerDisconnected", "MRB:Hooks:StopEvent", function(ply)
  if timer.Exists("MRB:Offers:Think:" .. ply:SteamID()) then
    timer.Remove("MRB:Offers:Think:" .. ply:SteamID())
  end
end)

hook.Add("OnPlayerChangedTeam","MRB:Hooks:StartEvent2", function(ply, bef)
  if ply:IsPlayer() then
    if mrobberycfg.teammu == team.GetName(bef) then
      if timer.Exists("MRB:Offers:Think:" .. ply:SteamID()) then
        timer.Remove("MRB:Offers:Think:" .. ply:SteamID())
      end
    end
  end
end)

hook.Add("PlayerButtonDown","MRB:Hooks:DropPaintings", function(ply, key)
  if key == mrobberycfg.keytodrop then
    if #mrobbery.f.GetPaintings(ply) > 0 then

      local malette = ents.Create("mr_malette")
      if (!IsValid(malette)) then return end
      malette:SetModel("models/props_c17/BriefCase001a.mdl")
      malette:SetPos(ply:GetPos() + Vector(0,10,10))
      malette:Spawn()
      malette.Paintings = mrobbery.f.GetPaintings(ply)
      malette:Setmrb_mpaintings(#mrobbery.f.GetPaintings(ply))

      ply:SetNWBool("mrb_carrying", false)

      mrobbery.f.logging(ply, mrobbery.language[mrobberycfg.language]["dp_mal_msg"])
      mrobbery.f.ClearPaintings(ply)
    end
  end
end)

hook.Add("PlayerDeath","MRB:Hooks:ClearPlayerOnDeath", function(ply, _, _)
  if IsValid(ply) and ply:IsPlayer() then
    mrobbery.f.ClearPaintings(ply)
  end
end)

hook.Add("PlayerSay", "MRB:Hooks:CmdIGConfig", function(ply, text)
  if IsValid(ply) and string.find(text:lower(), mrobberycfg.chatcmd) then
    if mrobbery.f.plyIsAdmin(ply) or ply:IsSuperAdmin() then
      net.Start("MRB:UI:CFG")
      net.WriteTable(mrobberycfg)
      net.Send(ply)
    else
      DarkRP.notify(ply, 1, 3, mrobbery.language[mrobberycfg.language]["need_staff"])
    end
    return ""
  end
end)

if mrobberycfg.losepaintings then
  hook.Add("OnPlayerChangedTeam","MRB:Hooks:ClearPlayerOnChangedTeam", function(ply, _, _)
    if IsValid(ply) and ply:IsPlayer() then
      mrobbery.f.ClearPaintings(ply)
      ply:SetNWBool("mrb_carrying", false)
    end
  end)
end

local entTable = {
    ["mr_alarm"] = true,
    ["mr_camera"] = true,
    ["mr_computer"] = true,
    ["mr_laser"] = true,
    ["mr_malette"] = true,
    ["mr_npc_reseller"] = true,
    ["mr_painting"] = true,
}

hook.Add("playerBoughtCustomEntity", "zcm_SetOwnerOnEntBuy", function(ply, _, ent, _)
    if entTable[ent:GetClass()] then
        ent:CPPISetOwner(ply)
    end
end)
