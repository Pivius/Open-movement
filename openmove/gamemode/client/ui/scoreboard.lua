local open = false
local scoreboard_alpha = 225
PLAYER_LINE =
{
	Init = function( self )
    SetFont("Score_P_Info", {
      font = "Gidole",
      weight = 1,
      size = 20,

    })
    self:Dock( TOP )



    self.infoOpened = false
    local w, h = self:GetSize()

    self.LineButton = self:Add( "DButton", self )
    self.LineButton:SetSize( 300, 32 )
    self.LineButton:SetText("")
    self.LineButton.DoClick = function()
      if self.infoOpened then
        self.infoOpened = false
      else
        self.infoOpened = true
      end
    end
    self.LineButton:SetAlpha(150)

    self.LineButton.Paint = function() end
		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:SetSize( 28, 28 )
		self.AvatarButton.DoClick = function()
      --self.Player:ShowProfile()
      gui.OpenURL( "https://steamcommunity.com/profiles/"..self.PURL )
    end

		function self.AvatarButton:Paint(w, h)
			return true
		end

		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:DockMargin( 16, 2, 0, 0 )

		self.Avatar	= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 28, 28  )
		self.Avatar:SetMouseInputEnabled( false )

    self.Name = self:Add( "EditablePanel" )
		self.Name:Dock( LEFT )
		self.Name:DockMargin( 0, 0, 0, 0 )
		self.Name:SetContentAlignment( 5 )
    self.Name:SetWide(999)
    self.Name.Paint = function(s, w, h )
      surface.SetFont(GetFont("Score_P_Info"))
      surface.SetTextColor(Color(255,255,255))
        draw_lib.Text(self.PNick, ((300-28-18)/2) - (self.PNick_Width/2),h/2, 3, 0, 0.5)
    end
    self.Name:SetMouseInputEnabled( false )
	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )

		self:Think( self )

	end,

	Think = function( self )
    local ply = self.Player
		if ( !IsValid( ply ) ) then
      self:SetZPos( 9999 ) -- Causes a rebuild
			self:Remove()
			return
		end
    local steamid = ply:SteamID()
		local topspeed = 0
    self.PURL = util.SteamIDTo64( steamid )
    if self.PNick != ply:Nick() then
      self.PNick = ply:Nick()
      local w, h = surface.GetTextSize( self.PNick )
      self.PNick_Width = w
    end
		--
		-- Connecting players go at the very bottom
		--
		if ( ply:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 )
		end

	end,
  PerformLayout = function( self )

		self:SetSize( 300, 32 )

	end,
	Paint = function( self, w, h )
    if self.LineButton:IsHovered() then
			self.LineButton:SetAlpha(Lerp(0.05, self.LineButton:GetAlpha(), 250))
    else
      self.LineButton:SetAlpha(Lerp(0.05, self.LineButton:GetAlpha(), scoreboard_alpha))
    end
		if ( !IsValid( self.Player ) ) then
			return
		end
		surface.SetDrawColor(Color(0, 0, 0, self.LineButton:GetAlpha()))

		surface.DrawRect(0, 0, 300, h)
	end
}

PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" )

local SCORE_BOARD =
{
	Init = function( self )
    SetFont("Score_Info", {
      font = "Gidole",
      weight = 300,
      size = 18
    })
    self.Bar= self:Add( "EditablePanel" )

    self.Bar:SetPos( 0, 15 )
    self.Bar:SetSize(300, 30)
    self.Bar.Paint = function(self, w, h )
      surface.SetDrawColor( Color(15,15,15,scoreboard_alpha) )
      surface.DrawRect(0, 0, w, h)
    end

    self.Profile= self.Bar:Add( "EditablePanel" )
		self.Profile:Dock( LEFT )
		self.Profile:DockMargin( 10, 0, 0, 0 )
		self.Profile:SetContentAlignment( 5 )
    self.Profile.Paint = function(self, w, h )

      surface.SetFont(GetFont("Score_Info"))
      surface.SetTextColor(Color(255,255,255))
      draw_lib.Text("Profile", 0,h/2, 3, 0, 0.5)
    end

    self.Name= self.Bar:Add( "EditablePanel" )
		self.Name:Dock( LEFT )
		self.Name:DockMargin( 85, 0, 0, 0 )
		self.Name:SetContentAlignment( 5 )
    self.Name.Paint = function(self, w, h )

      surface.SetFont(GetFont("Score_Info"))
      surface.SetTextColor(Color(255,255,255))
      draw_lib.Text("Nick", 0, h/2, 3, 0, 0.5)
    end

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 47 )

		self.List = self:Add( "DScrollPanel" )
		self.List:Dock( FILL )
		self.List:SetVerticalScrollbarEnabled(false)
    /*
    self.List.Paint = function(self, w, h )
      surface.SetDrawColor( Color(15,15,15,170) )
      surface.DrawRect(0, 0, w, h)
    end*/
		self.List.VBar:SetAlpha(0)

		self.List.offset = 0


		function self.List:OnVScroll(iOffset)
			self.offset = iOffset
		end

		function self.List:Think()
      self.offsetsmooth = self.offsetsmooth and Lerp(0.03, self.offsetsmooth , self.offset) or self.offset

      self.pnlCanvas:SetPos( 0, self.offsetsmooth )
		end


		function self.List:PerformLayout()
      local wide = self:GetWide()

      self:Rebuild()

      self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )

      if self.VBar.Enabled then wide = wide - self.VBar:GetWide() end

      self.pnlCanvas:SetWide(wide)

      self:Rebuild()
		end
	end,

	PerformLayout = function( self )

		self:SetSize( ScrW() - (250*2), ScrH()-100 )
		self:SetPos( 1, 0 )
	end,

	Paint = function( self, w, h )
	end,

	Think = function( self, w, h )

		-- table.sort(plyrs, function(a, b) return string.lower(a:Nick()) < string.lower(b:Nick()) end)

		for id, pl in pairs( player.GetAll() ) do

			if ( IsValid( pl.ScoreEntry ) ) then continue end
      --if ( IsValid( pl.ScoreInfo ) ) then continue end

			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )

			pl.ScoreEntry:Setup( pl )

      --pl.ScoreInfo = vgui.CreateFromTable( PLAYER_LINE_INFO, pl.ScoreInfo )
      --pl.ScoreInfo:Setup( pl )

			self.List:AddItem( pl.ScoreEntry )
      --self.List:AddItem( pl.ScoreInfo  )

		end

	end
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );

if ( IsValid( Scoreboard ) ) then
	Scoreboard:Remove()
end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()
	open = true

	if ( !IsValid( Scoreboard ) ) then
		Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( Scoreboard ) ) then
    Scoreboard:SetAlpha(0)
		Scoreboard:Show()
		Scoreboard:MakePopup()
		Scoreboard:SetKeyboardInputEnabled( false )
    Scoreboard:AlphaTo(255, 0.15)
	end

end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()
	open = false

	if ( IsValid( Scoreboard ) ) then
		timer.Simple(0.2, function()
			if not open then

				Scoreboard:Remove()
			end
		end)

		Scoreboard:AlphaTo(0, 0.15)
	end


end


--[[---------------------------------------------------------
   Name: gamemode:HUDDrawScoreBoard( )
   Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()

end
