include('shared.lua')
ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT
-- Scale renderbound with trail.
function ENT:Hook(bool, hitpos)
  if bool then
    self:SetHooked( bool )
    self:SetHitPos( hitpos )
  else
    self:SetHooked( bool )
  end
end

function ENT:updateBoundingBox()
  local renderOrigin = self:GetPos()
	local renderMins = renderOrigin
	local renderMaxs = renderOrigin
	local maxs, mins = Vector()
  if !self:GetHooked() then return end
  -- Node width
  local nWidth = Vector(5,5,5)
  mins = (self:GetPlayer():EyePos()-Vector(0,0,7)) - nWidth
  maxs = (self:GetPlayer():EyePos()-Vector(0,0,7)) + nWidth

  -- Gets the vector that is the furthest out.
  renderMins = Vector(math.min(renderMins.x, mins.x),math.min(renderMins.y, mins.y),math.min(renderMins.z, mins.z))
  renderMaxs = Vector(math.max(renderMaxs.x, maxs.x),math.max(renderMaxs.y, maxs.y),math.max(renderMaxs.z, maxs.z))

  mins = self:GetHitPos() - nWidth
  maxs = self:GetHitPos() + nWidth

  -- Gets the vector that is the furthest out.
  renderMins = Vector(math.min(renderMins.x, mins.x),math.min(renderMins.y, mins.y),math.min(renderMins.z, mins.z))
  renderMaxs = Vector(math.max(renderMaxs.x, maxs.x),math.max(renderMaxs.y, maxs.y),math.max(renderMaxs.z, maxs.z))

  -- Get localvector
	renderMins = renderMins - renderOrigin
  renderMaxs = renderMaxs - renderOrigin

  self:SetRenderBounds(renderMins, renderMaxs)
end

function ENT:Initialize()
  self:SetRenderAngles( Angle(0,0,0) )
  self:SetPlayer( self:GetParent() )
  self:SetHitPos( Vector(0,0,0) )
  self:SetHooked( false )
  self.Alpha = 0
end

function ENT:Think()
  self:updateBoundingBox()
  if self:GetHooked() then
    self.Alpha = self.Alpha and Lerp(0.25, self.Alpha, 255) or 255
  else
    self.Alpha = self.Alpha and Lerp(0.25, self.Alpha, 0) or 1
  end
end
function ENT:Draw()
  local Laser = Material( "zone/zone.png" )

  local col = Color(self:GetRopeColor().x, self:GetRopeColor().y, self:GetRopeColor().z, math.Round(self.Alpha))
  render.SetMaterial(Laser)

  if !self:GetHooked() then return end
  --if self:GetHooked() then

  if self:GetPlayer() == LocalPlayer() then

    --render.DrawBeam(self:GetPlayer():EyePos()-Vector(0,0,10), self:GetHitPos(), 2, 1, 1, col)
    /*
    render.StartBeam( 2 )
      render.AddBeam( self:GetPlayer():EyePos()-Vector(0,0,7) , 2, 1.0, col )
      render.AddBeam( self:GetHitPos() , 2, 1.0, col )
    render.EndBeam()*/
    --render.DrawWireframeSphere( self:GetHitPos(), self:GetPlayer().ropeLength, 10, 10, Color(255,255,255,255), true )

    if #self:GetPlayer():Intersections() >=1 then

      render.StartBeam( #self:GetPlayer():Intersections()+1 )
        for k, v in pairs(self:GetPlayer():Intersections()) do
            render.AddBeam( v , 3, 1.0, col )
        end
        --render.AddBeam( self:GetHitPos() , 2, 1.0, col )
        render.AddBeam( self:GetPlayer():EyePos()-Vector(0,0,7) , 0.75, 1.0, col )
      render.EndBeam()
    end
  else

    --render.DrawBeam(self:GetPlayer():EyePos()-Vector(0,0,10), self:GetHitPos(), 5, 1, 1, col)
    /*
    render.StartBeam( 2 )
      render.AddBeam( self:GetPlayer():EyePos()-Vector(0,0,5) , 5, 1.0, col )
      render.AddBeam( self:GetHitPos() , 5, 1.0, col )
    render.EndBeam()*/
    grabVar("Intersections", self:GetPlayer())
     -- Apparently doesn't work
    if #self:GetPlayer():Intersections() >=1 then
      render.StartBeam( #self:GetPlayer():Intersections()+1 )
        for k, v in pairs(self:GetPlayer():Intersections()) do
            render.AddBeam( v , 6, 1.0, col )
        end
        --render.AddBeam( self:GetHitPos() , 2, 1.0, col )
        render.AddBeam( self:GetPlayer():EyePos()-Vector(0,0,7) , 2, 1.0, col )
      render.EndBeam()
    end
  end

end

function ENT:DrawTranslucent()
self:Draw()

end
