local open = false

local SELECTION =
{
	Init = function( self )
    self.Background= self:Add( "EditablePanel" )
    self.Background:SetPos( 0, 0 )
    self.Background:SetSize(0, 0)
    self.Background.Paint = function(self, w, h )
      surface.SetDrawColor( Color(15,15,15,100) )
      surface.DrawRect(0, 0, w, h)
    end
    self.Modes = self:Add( "Custom_Button" )
    self.Modes:SetSize(250, 50)
    self.Modes:Dock(TOP)
    self.Modes:DockMargin(0,25,0,0)
    self.Modes:SetText("Modes")
    self.Modes:SetColor(Color(25,25,25,0))
    self.Modes:SetHighlight(Color(255,255,255,100))
    self.Modes.Button.OnClick = function()

    end
	end,

	PerformLayout = function( self )
    local x, y = 20, 20
    local w, h = 250, ScrH() - (20*2)
		self:SetSize( w, h )
		self:SetPos( x, y )
    self.Background:SetSize(w, h)
	end,

	Paint = function( self, w, h )
	end,

	Think = function( self, w, h )


	end
}

SELECTION = vgui.RegisterTable( SELECTION, "EditablePanel" );

if ( IsValid( Selection ) ) then
	Selection:Remove()
end

function GM:OnSpawnMenuOpen()

  gui.EnableScreenClicker(true)
	open = true

	if ( !IsValid( Selection ) ) then
		Selection = vgui.CreateFromTable( SELECTION )
    Selection:SetAlpha(0)
	end

	if ( IsValid( Selection ) ) then
    Selection:AlphaTo(255, 0.15)
		Selection:Show()
		Selection:MakePopup()
		Selection:SetKeyboardInputEnabled( false )
	end
end

function GM:OnSpawnMenuClose()
	open = false

	if ( IsValid( Selection ) ) then
		timer.Simple(0.2, function()
			if not open then
				Selection:Hide()
			end
		end)

		Selection:AlphaTo(0, 0.15)
	end
  gui.EnableScreenClicker(false)
end
