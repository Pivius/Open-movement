local white = Material("openmove/white.png")
function EFFECT:Init( effectdata )
	if !effectdata:GetEntity():IsValid() then return false end
	self.ply = effectdata:GetEntity()
	self.origin = effectdata:GetOrigin()
	--self:SetRenderBoundsWS( effectdata:GetOrigin(), tr.HitPos )
end
function EFFECT:Think()
    local pos = self.origin -- The origin position of the effect
    local emitter = ParticleEmitter( pos ) -- Particle emitter in this position

    for i = 0, 100 do -- Do 100 particles
    	local part = emitter:Add( white, pos ) -- Create a new particle at pos
    	if ( part ) then
    		part:SetDieTime( 1 ) -- How long the particle should "live"
				local cyan = math.random(150,255)
				part:SetColor( cyan, 255, 255 )
    		part:SetStartAlpha( 255 ) -- Starting alpha of the particle
    		part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

    		part:SetStartSize( 5 ) -- Starting size
    		part:SetEndSize( 0 ) -- Size when removed

    		part:SetGravity( Vector( 0, 0, 2 ) ) -- Gravity of the particle
    		part:SetVelocity( VectorRand() * 200 ) -- Initial velocity of the particle
    	end
    end

    emitter:Finish()

    local emitter = ParticleEmitter( pos ) -- Particle emitter in this position

    for i = 0, 100 do -- Do 100 particles
    	local part = emitter:Add( white, pos ) -- Create a new particle at pos
    	if ( part ) then
    		part:SetDieTime( 5 ) -- How long the particle should "live"
				local cyan = math.random(150,255)
				part:SetColor( cyan, 255, 255 )
    		part:SetStartAlpha( 255 ) -- Starting alpha of the particle
    		part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

    		part:SetStartSize( 2 ) -- Starting size
    		part:SetEndSize( 0 ) -- Size when removed

    		part:SetGravity( Vector( 0, 0, 1 ) ) -- Gravity of the particle
    		part:SetVelocity( VectorRand() * 5 ) -- Initial velocity of the particle
    	end
    end

    emitter:Finish()
end
function EFFECT:Render()

end
