ENT.Type        = "anim"
ENT.Base        = "base_gmodentity"

ENT.PrintName		= "Painting"
ENT.Author			= "Pilot2"
ENT.Category		= "Museum robbery"

ENT.Spawnable   = true
ENT.AdminOnly 	= true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()

  self:NetworkVar( "String", 0, "imgururl" )
  self:NetworkVar( "String", 1, "ImgurID" )
  self:NetworkVar( "String", 2, "imgurcrc" )

  self:NetworkVar( "Bool", 0, "stolen" )
	self:NetworkVar( "Bool", 1, "offered" )

  if SERVER then
    self:Setimgururl("")
    self:SetImgurID("")
    self:Setimgurcrc("")
    self:Setstolen(false)
    self:Setoffered(false)
  end
end
