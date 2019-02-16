function EFFECT:Init( effectdata )

	self.ply = effectdata:GetEntity()

	self.Alpha = 255--0
	self.UnHook = false
	self.Pos2 = self.ply:EyePos()-Vector(0,10,20)
	self.Pos = effectdata:GetOrigin()
	self.Active = self.ply:Grappling()
end

function EFFECT:Think()

	self:SetRenderBoundsWS( self.Pos, self.ply:EyePos()-Vector(0,10,20) )

	if !self.ply:Grappling() then
		self.UnHook = true
	end
	if self.UnHook then
		print(self.ply)
		self.Pos2 = self.Pos2 and LerpVector(0.007, self.Pos2, self.Pos) or self.Pos
		self.Alpha = self.Alpha and Lerp(0.1, self.Alpha, 1) or 1
		return math.Round(self.Alpha) != 1
	end
	if self.ply:Grappling() then
		self.Pos2 = self.ply:EyePos()-Vector(0,10,20)

	end

	return math.Round(self.Alpha) != 1

end

function EFFECT:Render()
	if math.Round(self.Alpha) == 1 then return end

	local Laser = Material( "trails/laser.vmt" )
  local col = Color(155, 255, 255, 255)
  render.SetMaterial(Laser)
  render.DrawBeam(self.Pos2, self.Pos, 10, math.random(50,60),math.random(90,100), Color(col.r, col.g, col.b, math.Clamp(self.Alpha, 1, col.a)))

end
