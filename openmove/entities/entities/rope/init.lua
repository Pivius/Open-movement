AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:Initialize()
  self:SetTrigger( true )
	self:DrawShadow( false )
	self:SetNotSolid( true )
	self:SetNoDraw( false )

  self.Phys = self:GetPhysicsObject()
	if self.Phys and self.Phys:IsValid() then
		self.Phys:Sleep()
		self.Phys:EnableCollisions( false )
	end
  self:SetPlayer( self:GetParent() )
  self:SetHitPos( Vector(0,0,0) )
  self:SetRopeColor(Vector(255,255,255))
  self:SetHooked( false )
end

function ENT:Hook(bool, hitpos, inter)

  if bool then
    self:SetHooked( bool )
    self:SetHitPos( hitpos )
  else
    self:SetHooked( bool )
  end
end
/*
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end*/
