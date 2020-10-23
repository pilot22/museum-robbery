local MODULE = GAS.Logging:MODULE()

MODULE.Category = "DarkRP"
MODULE.Name     = "Museum Robbery"
MODULE.Colour   =  Color(255, 0, 0)

MODULE:Setup(function()
	MODULE:Hook("MRB:Core", "MRB:Core:Logs", function(ply, msg)
		MODULE:Log(GAS.Logging:FormatPlayer(ply) .. msg)
	end)
end)

GAS.Logging:AddModule(MODULE)
