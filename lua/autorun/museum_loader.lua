-- Don't touch any file or no support will be provided.
mrobbery = mrobbery or {}
mrobbery.version = "2.0.0"
mrobbery.cache = {}
mrobbery.cachetodownload = {}
mrobbery.offers = mrobbery.offers or {}
mrobbery.pgsecured = false
mrobbery.lsenabled = false
mrobbery.language = mrobbery.language or {}
mrobbery.f = mrobbery.f or {}
mrobbery.lib = mrobbery.lib or {}
mrobbery.entities = mrobbery.entities or {}
mrobbery.entities["laser"] = mrobbery.entities["laser"] or {}
mrobbery.entities["paintings"] = mrobbery.entities["paintings"] or {}
mrobbery.entities["cameras"] = mrobbery.entities["cameras"] or {}
mrobbery.entities["alarms"] = mrobbery.entities["alarms"] or {}

function mrobbery.f.loadFile(strPath, boolInclude)
    local files, folders = file.Find(strPath .. "*", "LUA")

    for _, v in pairs(files) do
        if boolInclude then
            include(strPath .. v)
        else
            AddCSLuaFile(strPath .. v)
        end
    end

    for _, v in pairs(folders) do
        mrobbery.f.loadFile(strPath .. v .. "/", boolInclude)
    end
end

function mrobbery.f.loadresources(fdir)
    local files, dirs = file.Find(fdir .. "*", "GAME")

    for _, v in pairs(files) do
        resource.AddSingleFile(fdir .. v)
    end

    for _, dir in ipairs(dirs) do
        mrobbery.f.loadresources(fdir .. dir .. "/")
    end
end

function mrobbery.lib.loadModule(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, v in pairs(files) do
        if SERVER then
            if string.find(v, "cl_") or string.find(v, "sh_") then
                AddCSLuaFile(path .. v)
            end

            if string.find(v, "sv_") or string.find(v, "sh_") then
                include(path .. v)
            end
        else
            if string.find(v, "cl_") or string.find(v, "sh_") then
                include(path .. v)
            end
        end
    end

    for _, v in pairs(folders) do
        mrobbery.lib.loadModule(path .. v .. "/")
    end
end

if SERVER then
    print("Museum Robbery by Pilot2 is loading.")

    mrobbery.f.loadFile("museum_robbery/server/", true)
    mrobbery.f.loadFile("museum_robbery/shared/", true)
    mrobbery.f.loadFile("museum_robbery/shared/", false)
    mrobbery.f.loadFile("museum_robbery/client/", false)
    mrobbery.f.loadresources("sound/museum_robbery/")
    mrobbery.lib.loadModule("mrobbery_lib/modules/")

    resource.AddWorkshop("1863354376")
    resource.AddSingleFile("resource/fonts/museum_robbery/fa-solid-900.ttf")

    print("Museum Robbery by Pilot2 is loaded.")
elseif CLIENT then
    mrobbery.f.loadFile("museum_robbery/shared/", true)
    mrobbery.f.loadFile("museum_robbery/client/", true)
    mrobbery.lib.loadModule("mrobbery_lib/modules/")
    mrobbery.lib.loadModule("mrobbery_lib/modules/vgui/")
end
