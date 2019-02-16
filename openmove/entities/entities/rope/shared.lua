ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup		= "RENDERGROUP_TRANSLUCENT"
function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "HitPos" )
	self:NetworkVar( "Bool", 1, "Hooked" )
	self:NetworkVar( "Entity", 2, "Player" )
	self:NetworkVar( "Vector", 3, "RopeColor" )
end
