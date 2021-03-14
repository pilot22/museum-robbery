-- Don't touch any file or no support will be provided.
mrobbery = mrobbery or {
    ["version"] = "2.0.0",
    ["cache"] = {},
    ["cachetodownload"] = {},
    ["offers"] = {},
    ["pgsecured"] = false,
    ["lsenabled"] = false,
    ["language"] = {},
    ["f"] = {},
    ["lib"] = {},
    ["entities"] = {
        ["laser"] = {},
        ["paintings"] = {},
        ["cameras"] = {},
        ["alarms"] = {}.
    },
}

function mrobbery.f.loadFile(strPath, boolInclude)
    local files, folders = file.Find(strPath .. "*", "LUA")

    for _, v in ipairs(files) do
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

    for _, v in ipairs(files) do
        resource.AddSingleFile(fdir .. v)
    end

    for _, dir in ipairs(dirs) do
        mrobbery.f.loadresources(fdir .. dir .. "/")
    end
end

function mrobbery.lib.loadModule(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, v in ipairs(files) do
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

    for _, v in ipairs(folders) do
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
