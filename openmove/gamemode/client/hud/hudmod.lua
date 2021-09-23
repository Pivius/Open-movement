hudmod = {}

-- View table
hudmod.View = {}
hudmod.View.zFar = 0
hudmod.View.zNear = 0
hudmod.View.FOV = 0
hudmod.View.Ang = Angle(0,0,0)
hudmod.View.Pos = Vector(0,0,0)

hudmod.Panels = {}

local function viewUpdate( ply, pos, ang, fov, znear, zfar )
  if IsValid(LocalPlayer()) then
    ply.zFar = zfar
    ply.zNear = znear
    ply.FOV = fov
    ply.vAng = ang
    ply.vPos = pos
  end
end
hook.Add( 'CalcView', 'view_Update', viewUpdate )


function hudmod.finishMove(ply, mv)
  for name, pnl in pairs(hudmod.Panels) do
    if IsValid( pnl ) and pnl.moveUpdate then
      pnl:Move( ply, mv )
    end
  end
end
hook.Add( 'FinishMove', 'hudmod.finishMove', hudmod.finishMove)

function hudmod.getZFar()
  return LocalPlayer().zFar or 0
end

function hudmod.getZNear()
  return LocalPlayer().zNear or 0
end

function hudmod.getFOV()
  return LocalPlayer().FOV or 70
end

function hudmod.getViewAngle()
  return LocalPlayer().vAng or Angle( 0, 0, 0 )
end

function hudmod.getViewPos()
  return LocalPlayer().vPos or Vector( 0, 0, 0 )
end

function hudmod.getPanel(pnl)
  return hudmod.Panels[pnl]
end

local function Render()
  local ply = LocalPlayer()
  hudmod.View.zFar = ply.zFar
  hudmod.View.zNear = ply.zNear
  hudmod.View.FOV = ply.FOV
  hudmod.View.Ang = ply.vAng

  hudmod.View.Pos = ply.vPos

  for name, pnl in pairs(hudmod.Panels) do

    if pnl then

      pnl:DrawCam()
    end
  end
end
hook.Add( "RenderScreenspaceEffects", "HUD.Render", Render )

/*
  3D Rendering
*/

local PANEL = {}

function PANEL:Init()
  self:SetSize( ScrW(), ScrH() )
  self:SetPos( 0, 0 )
  self.Name = #hudmod.Panels+1
  -- Tilt
  self.Tiltable = true
  self.tiltDelta = Angle(0,0,0)
  self.oldTiltAngle = Angle(0,0,0)
  self.resetRate = 3
  self.tiltRate = 50

  self.Distance = 1
  self.offsetUp = 0
  self.offsetSide = 0
  self.offsetCam = Vector(0,0,0)

  self.sideAng = 0
  self.upAng = 0
  self.spin = 0
  -- Offset according to movement
  self.move = false
  self.moveUpdate = false
  self.Alpha = 255

  hudmod.Panels[self.Name] = self

end

function PANEL:setName(name)
  local oldName = self.Name
  if !name then
    self.Name = #hudmod.Panels
    hudmod.Panels[oldName] = false
    hudmod.Panels[self.Name] = self
  end
  self.Name = name
end

function PANEL:Move(ply,mv)

end

function PANEL:setDistance(dist)
  if not dist then self.Distance = 1 end
  self.Distance = dist
end

function PANEL:setAngle(side, up)
  if !side then side = self.sideAng end
  if !up then up = self.upAng end
  self.upAng = up
  self.sideAng = side
end

function PANEL:OnRemove()
    self.moveUpdate = false
    hudmod.Panels[self.Name] = false

end

function PANEL:PerformLayout( w, h )

end

function PANEL:Tilt()
  self.tiltDelta = hudmod.getViewAngle() - self.oldTiltAngle
  if not ((self.tiltDelta.y > 90) or (self.tiltDelta.y < -90)) then
    self.offsetSide = self.offsetSide + ((self.tiltDelta.y - self.offsetSide*(self.resetRate/10)) * (self.tiltRate/100))
  end

  if not ((self.tiltDelta.p > 90) or (self.tiltDelta.p < -90)) then
    self.offsetUp = self.offsetUp + ((self.tiltDelta.p - self.offsetUp*(self.resetRate/10)) * (self.tiltRate/100))
  end
  self.oldTiltAngle = hudmod.getViewAngle()
end

function PANEL:DrawCam()

  local x, y = self:GetPos()
  local camPos = hudmod.getViewPos() + self.offsetCam
  local camAng = hudmod.getViewAngle()
  local aspectRatio = ScrW()/ScrH()
  local distance = hudmod.getZNear() * self.Distance * 160
  local frustH = 2 * (distance) * (math.tan( math.rad(90*0.5) ))
  local frustW  = frustH * aspectRatio
  --local aRatio = (frustW-frustH)/(ScrW()-ScrH())
  local fARatio    = frustW / frustH
  --local w, h = frustW / ScrW() / aRatio, frustH / ScrH() / aRatio
  self:Tilt()
  local  ang = Angle( camAng.p-(self.offsetUp*2), (camAng.y)-(self.offsetSide/2),  0)
  -- Center the 3D2D cam in 3D cam and move forward
  --local xOffset = ang:Right() * -((frustW) / (ScrW()) )
  --local yOffset = ang:Up() * ((frustH) / (ScrH()))
  --local zOffset = (ang:Forward()*self.Distance) * ((hudmod.getZNear())*aspectRatio)
  --camPos = camPos+zOffset+xOffset+yOffset
  --local xOffset = ang:Right()

  local xOffset = ang:Right()
  local yOffset = ang:Up()
  local zOffset = (ang:Forward()*distance) * fARatio
  camPos = camPos+zOffset+yOffset+xOffset
  --pos = pos - self.movementOffset
  ang:RotateAroundAxis( ang:Right(), 90+(self.upAng-self.offsetUp*2.5) )
  ang:RotateAroundAxis( ang:Forward(), 0+(self.sideAng-self.offsetSide*2.5))
  ang:RotateAroundAxis( ang:Up(), -90)
  self.ScrW = frustW/2
  self.ScrH = frustH/2
  cam.Start3D( hudmod.getViewPos(), camAng, 90)
    surface.DisableClipping(true)
      cam.Start3D2D( camPos, ang, 1)
        cam.IgnoreZ(true)
          self:Draw3D(LocalPlayer(), frustW/2, frustH/2)
        cam.IgnoreZ(false)
      cam.End3D2D()
    surface.DisableClipping(false)
  cam.End3D()
  self.spin = self.spin + 10
end

function PANEL:Draw3D(ply, scrw, scrh)

  --print("a")
  -- Draw Function
end
vgui.Register( '3DPanel', PANEL )

function hudmod.CreatePanel( dist, tilt, reset, side, up, move )
  local panel = vgui.Create( "3DPanel" )

  panel.Distance = dist or 1.65
  panel.tiltRate = tilt or 50
  panel.resetRate = reset or 3
  panel.sideAng = side or 0
  panel.upAng = up or 0
  panel.moveUpdate = move or false

  return panel
end
