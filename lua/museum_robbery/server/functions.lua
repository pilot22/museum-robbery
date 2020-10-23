-- Do not touch this file !

mrobbery.debug = false -- Leave this value if you don't know what you are doing :)

function mrobbery.f.ReloadConfig()
    if file.Exists("museum_robbery/config.txt", "DATA") then
        mrobberycfg = {}
        mrobberycfg = util.JSONToTable(file.Read("museum_robbery/config.txt", "DATA"))

        if player.GetCount() >= 1 then
            mrobbery.f.BroadcastCFG()
        end
    else
        file.CreateDir("museum_robbery") -- first initialization here
        mrobberycfg = {}
        mrobberycfg.language = "FR"
        mrobberycfg.timetosteal = 6
        mrobberycfg.pricepp = 2000
        mrobberycfg.chatcmd = "!mrconfig"
        mrobberycfg.maletteoply = true
        mrobberycfg.timebet = 20
        mrobberycfg.offertime = 15
        mrobberycfg.percent = 10
        mrobberycfg.maxdisttosteal = 100
        mrobberycfg.keytodrop = KEY_G
        mrobberycfg.maxcarrypaintings = 4
        mrobberycfg.hacktime = 15
        mrobberycfg.offeraminperpt = 150
        mrobberycfg.timeoffer = 150
        mrobberycfg.offermaxperpt = 450
        mrobberycfg.reseller_skin = "models/Humans/Group01/male_02.mdl"
        mrobberycfg.reseller_nameover = true
        mrobberycfg.reseller_name = "Reseller"
        mrobberycfg.hackedtime = 60
        mrobberycfg.wantedde = true
        mrobberycfg.wantedha = true
        mrobberycfg.statsenabled = true
        mrobberycfg.wantedst = true
        mrobberycfg.uselogging = true
        mrobberycfg.minmuseumanag = 1
        mrobberycfg.losepaintings = true

        mrobberycfg.admingroups = {
            ["superadmin"] = true
        }

        mrobberycfg.teammu = "Museum Manager"

        mrobberycfg.teamro = {
            ["Citizen"] = true
        }

        file.Write("museum_robbery/config.txt", util.TableToJSON(mrobberycfg))
        print("\tThe config has been loaded for the first time !")
        mrobbery.f.ReloadConfig()
    end
end

if not mrobberycfg then
    mrobbery.f.ReloadConfig()
end

-- Load the config once the file is loaded
function mrobbery.f.SetVarBool(int, bool)
    net.Start("MRB:UpdateSpeVar")
    net.WriteInt(int, 6)
    net.WriteBool(bool)
    net.Broadcast()
end

function mrobbery.f.logging(ply, message)
    if GAS and GAS.Logging and mrobberycfg.uselogging then
        hook.Call("MRB:Core", nil, ply, message)
    end
end

function mrobbery.f.Secure(int)
    if not isnumber(int) then return end
    local lasers = mrobbery.entities.laser
    local paintings = mrobbery.entities.paintings

    if int == 1 then
        if not mrobbery.pgsecured then
            mrobbery.pgsecured = true
            mrobbery.f.SetVarBool(int, true)

            for _, v in pairs(paintings) do
                if not IsValid(v) or v:Getstolen() or v:Getoffered() then continue end
                v:SetSubMaterial(2, "museum_robbery/sycreations/security_frame/ts_shutter_closed")
            end
        else
            mrobbery.pgsecured = false
            mrobbery.f.SetVarBool(int, false)

            for _, v in pairs(paintings) do
                if not IsValid(v) or v:Getstolen() or v:Getoffered() then continue end
                v:SetSubMaterial(2, "museum_robbery/sycreations/security_frame/ts_shutter_open")
            end
        end
    elseif int == 2 then
        if not mrobbery.lsenabled then
            mrobbery.lsenabled = true
            mrobbery.f.SetVarBool(int, true)

            for _, v in pairs(lasers) do
                if not IsValid(v) then continue end
                v:Setlaserstate(true)
            end
        else
            mrobbery.lsenabled = false
            mrobbery.f.SetVarBool(int, false)

            for _, v in pairs(lasers) do
                if not IsValid(v) then continue end
                v:Setlaserstate(false)
            end
        end
    end
end

function mrobbery.f.BroadcastCache(ply)
    net.Start("MRB:UpdateSpeVar")
    net.WriteInt(3, 6)
    net.WriteBool(false)
    net.WriteTable(mrobbery.cache)

    if ply and ply:IsValid() and ply:IsPlayer() then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function mrobbery.f.SmartCacheByPainting(ent)
    if not isentity(ent) then
        error("Entity passed in function mrobbery.f.SmartCacheByPainting() isn't an entity")

        return
    end

    local checke = false

    for _, v in pairs(mrobbery.entities.paintings) do
        if v:GetImgurID() == ent:GetImgurID() and v ~= ent then
            checke = true
            break
        end
    end

    -- We don't want to uncache an picture if she is used on another painting
    if not checke then
        mrobbery.cache[util.CRC(ent:Getimgururl())] = false -- Uncache
        mrobbery.cachetodownload[ent:Getimgururl()] = false -- Uncache
        mrobbery.f.BroadcastCache() -- Broadcast the new cache
    end
end

function mrobbery.f.MatFromURL(url, ply, ent)
    -- We don't want to cache the url if it is already cached
    if mrobbery.cache[ent:Getimgurcrc()] ~= true then
        mrobbery.cache[ent:Getimgurcrc()] = true
        mrobbery.cachetodownload[url] = true
    end

    net.Start("MRB:DLMAT") -- Sending the instruction to download the material to the clients
    net.WriteString(url)
    net.WriteEntity(ent)
    net.Broadcast()
    ent:SetSubMaterial(1, "!" .. ent:Getimgurcrc()) -- We set the material serverside & clientside to prevent an issue already reported on github of garrysmod.

    if ply then
        mrobbery.f.logging(ply, mrobbery.language[mrobberycfg.language]["change_log_msg"]:format(url))
    end
end

function mrobbery.f.FindEnt(ply, maxrange, class)
    for _, v in pairs(ents.FindInSphere(ply:GetPos(), maxrange)) do
        if v:GetClass() == class then return v end
    end

    return nil
end

function mrobbery.f.checkgoodent(p, entgood)
    local ent = p:GetEyeTrace().Entity

    if (ent:GetClass() ~= entgood) then
        return mrobbery.f.FindEnt(p, 100.9, entgood)
    else
        return ent
    end
end

function mrobbery.f.IsStringURL(url)
    if not isstring(url) or url == "" then return false end
    if string.len(url) < 7 then return false end
    if not string.match(url:lower(), "(h?t?t?p?s?:?/?/?w?w?w?.?%w+.%w+/)") then return false end
    if not string.find(url:lower(), ".png") and not string.find(url:lower(), ".jpg") and not string.find(url:lower(), ".gif") and not string.find(url:lower(), ".jpeg") then return false end

    return true
end

function mrobbery.f.AddPaintingsByEntity(ply, ent)
    if isentity(ent) and IsValid(ply) then
        if not IsValid(ply) or not IsValid(ent) then return end
        ply.paintings[#ply.paintings + 1] = true
        ply:SetNWInt("mrb_paintings", ply:GetNWInt("mrb_paintings") + 1)
    end
end

function mrobbery.f.AddPaintingsByTable(ply, table)
    if istable(table) and IsValid(ply) then
        for _, _ in pairs(table) do
            ply.paintings[#ply.paintings + 1] = true
            ply:SetNWInt("mrb_paintings", ply:GetNWInt("mrb_paintings") + 1)
        end
    end
end

function mrobbery.f.ClearPaintings(ply)
    if not IsValid(ply) then return end
    ply.paintings = {}
    ply:SetNWInt("mrb_paintings", 0)
    ply:SetNWBool("mrb_carrying", false)
end

function mrobbery.f.AddMoney(ply, amount)
    if not IsValid(ply) or not isnumber(amount) then return end
    ply:addMoney(amount)
end

function mrobbery.f.GetPaintings(ply)
    if not IsValid(ply) then return {} end

    return ply.paintings or {}
end

function mrobbery.f.plyIsAdmin(ply)
    if not IsValid(ply) then return end
    if mrobberycfg.admingroups[ply:GetUserGroup()] then return true end

    return false
end

function mrobbery.f.plyIsRobber(ply)
    if not IsValid(ply) then return end
    if mrobberycfg.teamro[team.GetName(ply:Team())] then return true end

    return false
end

function mrobbery.f.SellPaintings(ply, infos)
    if IsValid(ply) then
        mrobbery.f.AddMoney(ply, infos.price)
        DarkRP.notify(ply, 2, 3, string.format(mrobbery.language[mrobberycfg.language]["paintings_sold"], tostring(DarkRP.formatMoney(table.price))))
        ply.paintings[k] = nil

        if ply:GetNWInt("mrb_paintings") >= 1 then
            ply:SetNWInt("mrb_paintings", ply:GetNWInt("mrb_paintings") - 1)
        end

        if #mrobbery.f.GetPaintings(ply) == 0 then
            ply:SetNWInt("mrb_paintings", 0)
            ply:SetNWBool("mrb_carrying", false)
        end
    end
end

function mrobbery.f.BroadcastCFG(ply)
    net.Start("MRB:UpdateSpeVar")
    net.WriteInt(6, 6)
    net.WriteBool(true)
    net.WriteTable(mrobberycfg)

    if not ply then
        net.Broadcast()
    elseif ply:IsPlayer() and ply:IsValid() then
        net.Send(ply)
    end
end

function mrobbery.f:Debug(value)
    if not mrobbery.debug then return end

    if isstring(value) or isentity(value) then
        print(value)
    elseif istable(value) then
        PrintTable(value)
    end
end

local paintingsclean = {}
local paintingschoosen = {}

function mrobbery.offers:Thinking(ply)
    timer.Create("MRB:Offers:Think:" .. ply:SteamID(), mrobberycfg.offertime + mrobberycfg.timebet, 0, function()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if (team.GetName(ply:Team()) ~= mrobberycfg.teammu) then return end
        mrobbery.f:Debug("debug1")

        if #mrobbery.entities.paintings > 0 then
            ply.curoffer = {} -- Initialize and/or reset the current offer of the player
            paintingsclean = {} -- Reset the table (defined as local at line 5)

            for _, v in pairs(mrobbery.entities.paintings) do
                if IsValid(v) and v:GetSubMaterial(1) ~= "" and v:Getoffered() ~= true and v:Getimgururl() ~= "" and v:Getstolen() == false and not mrobbery.pgsecured then
                    paintingsclean[#paintingsclean + 1] = v
                end
            end

            mrobbery.f:Debug("debug2")

            -- If there is no paintings with pictures, no offers !
            if paintingsclean then
                mrobbery.f:Debug("debug3")
                local randomnum = math.random(1, #paintingsclean)
                local entrand = table.Random(mrobbery.offers.enterprises["Names"])
                paintingschoosen = {} -- Reset the table (defined as local at line 6)

                for i = 1, randomnum do
                    local pt = paintingsclean[math.random(1, #paintingsclean)] -- Generate a new random every iteration
                    local found = false

                    for _, v in pairs(paintingschoosen) do
                        mrobbery.f:Debug(v)

                        -- We don't want to add two times or more the same painting
                        if v == pt then
                            mrobbery.f:Debug(v, pt)
                            found = true
                            break
                        end
                    end

                    mrobbery.f:Debug(found)

                    if not found then
                        paintingschoosen[#paintingschoosen + 1] = pt
                    end
                end

                mrobbery.f:Debug(paintingschoosen)

                -- We dont want to make an offer without paintings available
                if #paintingschoosen > 0 then
                    mrobbery.f:Debug("debug4")
                    local ptsnum = #paintingschoosen

                    local currentoffer = {
                        entname = entrand, -- Enterprise name
                        pts = ptsnum, -- Amount of paintings
                        price = math.random(mrobberycfg.offeraminperpt * ptsnum, mrobberycfg.offermaxperpt * ptsnum), -- The amount what the enterprise will pay
                        starttime = CurTime(), -- Start time of the offer
                        paintings = paintingschoosen -- Table of the paintings who are concerned
                    }

                    ply.curoffer = currentoffer -- Define the offer on the player for later
                    net.Start("MRB:Offer")
                    net.WriteTable(currentoffer)
                    net.Send(ply)
                    mrobbery.f.logging(ply, mrobbery.language[mrobberycfg.language]["offer"]:format(entrand, DarkRP.formatMoney(prce)))
                end
            end
        end
    end)
end