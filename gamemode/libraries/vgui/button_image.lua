local BUTTON =
{

  Init = function( self )
    self.Font = "Trebuchet24"
    self.Text = ""

    self.Color = Color(255,255,255, 50)
    self.Highlight = Color(0,0,0)
    local alpha = 0

    self.ButtonColor = self:Add( "DModelPanel" )

    self.ButtonColor:SetAlpha(255)
    self.ButtonColor:SetColor(self.Color)
    self.ButtonColor:SetSize( 0, 0 )

    self.Button = self:Add( "DButton" )
    self.Alpha = vgui.Create("DButton")
    self.Alpha:SetSize(0,0)
    self.Alpha:SetAlpha(self.Color.a)
    self.Img = Material("shapes/Circle32")
    self.Alpha:SetText("")
    self.Alpha.Paint = function(self, w, h)
      surface.SetDrawColor( Color(255,255,255, 255) )
      surface.DrawRect(0, 0, w, h)
    end

    self.Button:SetText("")
    local alphabut = self.Alpha
    local colorbut = self.ButtonColor
    self.Button:SetSize(self:GetWide(),self:GetTall())
    --self.Button:Dock(TOP)
    self.Button.OnClick = function()
    end
    self.Button.DoClick = function()
      self.Button.OnClick()
      alphabut:SetAlpha(250)
      alphabut:AlphaTo( alpha, 0.2, 0)
      colorbut:SetColor(self.Highlight)
      colorbut:ColorTo(self.Color, 0.2)
    end
    self.Button:SetAlpha(255)
    self.Button.OnCursorEntered = function(self)
      alpha = self:GetParent().Color.a+50
      alphabut:AlphaTo( alpha, 0.3 , 0)
    end

    self.Button.OnCursorExited = function(self)
      alpha = self:GetParent().Color.a
      alphabut:AlphaTo( alpha, 0.3 , 0)
    end

    self.Button.Paint = function(self, w, h)

      surface.SetDrawColor( Color(colorbut:GetColor().r,colorbut:GetColor().g,colorbut:GetColor().b, alphabut:GetAlpha()) )
      surface.SetMaterial( self:GetParent().Img	)
      surface.DrawTexturedRect( 0, 0, w, h )


    end

	end,
  Update = function(self)
    if !self.Button then return end
    self.ButtonColor:SetColor(self.Color)
    self.Alpha:SetAlpha(self.Color.a)

    self.Button:SetText("")
    self.Button:SetSize(self:GetWide(),self:GetTall())
  end,

  SetImg = function(self, img)
    self.Img = Material(img)
  end,

  SetColor = function(self, col)
    self.Color = col
    self:Update()
  end,

  SetHighlight = function(self, h)
    self.Highlight = h
    self:Update()
  end,
	Paint = function( self, w, h )
	end,

  Think = function( self, w, h )
  end
}

vgui.Register( "Image_Button", BUTTON, "EditablePanel" )
