// NE PAS TOUCHER AU "TEAM_MUSEUM =". L'addon ne marchera pas comme prévu.

TEAM_MUSEUM = DarkRP.createJob("Museum Manager", {
    color = Color(225, 75, 75, 255),
    model = {"models/player/group03/male_04.mdl"},
    description = [[You are the Museum Manager, you must manage your museum. Be careful about heisters !]],
    weapons = {},
    command = "museumg",
    max = 2,
    salary = 250, -- I think you should give a salary to the museum manager to make them want use this job !
    admin = 0,
    vote = false,
    category = "Citizens",
    hasLicense = false
})

TEAM_RAIDER = DarkRP.createJob("Raider", {
    color = Color(225, 75, 75, 255),
    model = {"models/player/group03/male_04.mdl"},
    description = [[You are a "museum raider", you should rob the museum to make money...]],
    weapons = {},
    command = "teamraider",
    max = 2,
    salary = 0,
    admin = 0,
    vote = false,
    category = "Citizens",
    hasLicense = false
})

DarkRP.createCategory{
      name = "Museum",
      categorises = "entities",
      startExpanded = true,
      color = Color(255, 107, 0, 255),
      canSee = function(ply) return TEAM_MUSEUM == ply:Team() end,
      sortOrder = 104
  }

  DarkRP.createEntity("Painting", {
      ent = "mr_painting",
      model = "models/props/museum_robbery/sycreations/security_frame/ts.mdl",
      price = 200,
      max = 10,
      cmd = "buymrb_painting",
      allowed = TEAM_MUSEUM,
      category = "Museum"
  })

  DarkRP.createEntity("Camera", {
      ent = "mr_camera",
      model = "models/blackghost/blackghost_camera_pilot.mdl",
      price = 100,
      max = 4,
      cmd = "buymrb_cam",
      allowed = TEAM_MUSEUM,
      category = "Museum",
      isillegal = true,      
  })

  DarkRP.createEntity("Alarm", {
      ent = "mr_alarm",
      model = "models/props_wasteland/speakercluster01a.mdl",
      price = 80,
      max = 4,
      cmd = "buymrb_alarm",
      allowed = TEAM_MUSEUM,
      category = "Museum"
  })

  DarkRP.createEntity("Laser", {
      ent = "mr_laser",
      model = "models/props/sycreations/laser/laser.mdl",
      price = 120,
      max = 6,
      cmd = "buymbr_laser",
      allowed = TEAM_MUSEUM,
      category = "Museum"
  })

  DarkRP.createEntity("Computer", {
      ent = "mr_computer",
      model = "models/props/cs_office/computer.mdl",
      price = 120,
      max = 1,
      cmd = "buymrb_computer",
      allowed = TEAM_MUSEUM,
      category = "Museum"
  })
