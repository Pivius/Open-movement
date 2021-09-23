local white = Material("openmove/white.png")

function EFFECT:Init( effectdata )
	if !effectdata:GetEntity():IsValid() then return false end
  self.ply = effectdata:GetEntity()
  self.origin = effectdata:GetOrigin()
  self.maxParticles = 2
	--self:SetRenderBoundsWS( effectdata:GetOrigin(), tr.HitPos )
end
function EFFECT:Think()
  local pos = self.origin -- The origin position of the effect
  local emitter = ParticleEmitter( pos ) -- Particle emitter in this position
  local part = emitter:Add( white, pos ) -- Create a new particle at pos
  if ( part ) then
  	part:SetDieTime( 0.3 ) -- How long the particle should "live"
		local cyan = math.random(0,150)
		part:SetColor( cyan, cyan, 255 )
  	part:SetStartAlpha( 255 ) -- Starting alpha of the particle
  	part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
  	part:SetStartSize( 5 ) -- Starting size
  	part:SetEndSize( 0 ) -- Size when removed
  	part:SetGravity( Vector( 0, 0, 200 ) ) -- Gravity of the particle
  	part:SetVelocity( VectorRand() * 30 ) -- Initial velocity of the particle
  end
  emitter:Finish()
  local emitter = ParticleEmitter( pos ) -- Particle emitter in this position
  local part = emitter:Add( white, pos ) -- Create a new particle at pos
  if ( part ) then
  	part:SetDieTime( 2 ) -- How long the particle should "live"
		local cyan = math.random(150,255)
		part:SetColor( cyan, 255, 255 )
  	part:SetStartAlpha( 50 ) -- Starting alpha of the particle
  	part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

  	part:SetStartSize( 5 ) -- Starting size
  	part:SetEndSize( 0 ) -- Size when removed

  	part:SetGravity( Vector( 0, 0, 2 ) ) -- Gravity of the particle
  	part:SetVelocity( VectorRand() * 30 ) -- Initial velocity of the particle
  end
  emitter:Finish()
end
function EFFECT:Render()

end
