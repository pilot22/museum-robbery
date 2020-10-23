-- Do not touch this file !
util.AddNetworkString("MRB:UI:PC")
util.AddNetworkString("MRB:UI:PC:HACK")
util.AddNetworkString("MRB:UI:PC:UPDATE")
util.AddNetworkString("MRB:UI:CAM")
util.AddNetworkString("MRB:UI:BtnSec")
util.AddNetworkString("MRB:UI:BtnCam")
util.AddNetworkString("MRB:Stealing")
util.AddNetworkString("MRB:UI:HACK:Start")
util.AddNetworkString("MRB:UI:HACK:Cancel")
util.AddNetworkString("MRB:Painting")
util.AddNetworkString("MRB:UI:Painting:Edited")
util.AddNetworkString("MRB:RESELLER")
util.AddNetworkString("MRB:UI:CFG")
util.AddNetworkString("MRB:UI:CFG:UPDATE")
util.AddNetworkString("MRB:DLMAT")
util.AddNetworkString("MRB:SendConfig")
util.AddNetworkString("MRB:UpdateSpeVar")
util.AddNetworkString("MRB:Offer")

-- Receive the acceptation of the player
net.Receive("MRB:Offer", function(_, ply)
    if not ply:IsPlayer() or team.GetName(ply:Team()) ~= mrobberycfg.teammu or not ply.curoffer then return end -- Some checks
    local offer = ply.curoffer
    local url = "https://i.imgur.com/lgCR9c5.png"
    local crc = util.CRC(url)
    net.Start("MRB:DLMAT") -- Sending the instruction to download the material to the clients
    net.WriteString(url)
    net.Broadcast()
    ply:ChatPrint(mrobbery.language[mrobberycfg.language]["pt_offed"])
    ply:ChatPrint(mrobbery.language[mrobberycfg.language]["pt_offed_gain"]:format(offer.entname, DarkRP.formatMoney(offer.price)))
    ply:addMoney(offer.price)

    for _, v in pairs(offer.paintings) do
        if IsValid(v) and v:GetSubMaterial(1) ~= "" and v:Getoffered() ~= true and v:Getimgururl() ~= "" and v:Getstolen() == false and not mrobbery.pgsecured then
            -- We don't want to recache the url if it is already cached
            if not mrobbery.cache[crc] then
                mrobbery.cache[crc] = true
                mrobbery.cachetodownload[url] = true
            end

            v:Setimgururl(url)
            v:Setimgurcrc(crc)
            v:Setoffered(true)
            v:SetSubMaterial(1, "!" .. crc) -- We set the material serverside & clientside to prevent an issue already reported on github of garrysmod.

            timer.Simple(mrobberycfg.timeoffer, function()
                local new_url = v.prev or "nil"
                local new_url_crc = util.CRC(new_url)
                v:Setimgururl(new_url)
                v:SetImgurID(v:GetImgurID())
                v:Setimgurcrc(new_url_crc)
                mrobbery.f.MatFromURL(new_url, nil, v)
                v:Setoffered(false)
                mrobbery.f.SmartCacheByPainting(v)
            end)
        end
    end

    timer.Simple(mrobberycfg.timeoffer, function()
        ply:ChatPrint(mrobbery.language[mrobberycfg.language]["pt_unoffered"]) -- Paintings are back, this is time to advert to the museum manager.
    end)

    ply.curoffer = {} -- Reinitialize the curoffer table on the player
end)

net.Receive("MRB:UI:CFG:UPDATE", function(_, ply)
    if IsValid(ply) and ply:Alive() and (ply:IsSuperAdmin() or mrobbery.f.plyIsAdmin(ply)) then
        local newconfig = net.ReadTable()

        -- Check if the language is valid (to prevent misconfiguration of the language)
        if mrobbery.language[newconfig.language] then
            file.Write("museum_robbery/config.txt", util.TableToJSON(newconfig))
            mrobbery.f.ReloadConfig()
            DarkRP.notify(ply, 0, 4, mrobbery.language[mrobberycfg.language]["config_up"])
        else
            ply:ChatPrint(mrobbery.language[mrobberycfg.language]["misconfig"]:format("\"" .. mrobbery.language[mrobberycfg.language]["language"] .. "\"", "EN / FR"))
        end
    end
end)

net.Receive("MRB:Painting", function(_, ply)
    local id = net.ReadString()
    local url = "https://i.imgur.com/" .. id .. ".png"
    local ent = ply:GetEyeTrace().Entity

    if ply:IsPlayer() and team.GetName(ply:Team()) == mrobberycfg.teammu and IsValid(ent) and ent == ply.ptediting and ent:Getoffered() ~= true then
        if not mrobbery.f.IsStringURL(url) then
            DarkRP.notify(ply, 1, 3, mrobbery.language[mrobberycfg.language]["enter_url_v"])

            return
        end

        if ent:Getimgururl() ~= url then
            ent:Setimgururl(url)
            ent:SetImgurID(id)
            ent:Setimgurcrc(util.CRC(url))
            mrobbery.f.MatFromURL(url, ply, ent)
            ent.prev = url
        end
    end
end)

timer.Simple(.1, function()
    local statstbl = {
        servername = GetHostName(),
        license = "GITH_1.1.3-(23/10/20)",
        version = mrobbery.version
    }

    if mrobberycfg.statsenabled then
        http.Post("http://museum-robbery.000webhostapp.com/stats/post.php", statstbl)
    end
end)