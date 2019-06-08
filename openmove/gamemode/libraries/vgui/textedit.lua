local TEXTEDIT =
{

  Init = function( self )
    self.Font = "Trebuchet24"
    self.Text = ""
    self.DefText = ""
    self.Numeric = false
    self.ClickText = ""
    self.OnType = function() end
    self.OnEnter = function() end
    self.Color = Color(255,255,255, 50)
    self.Highlight = Color(0,0,0)
    local alpha = 0

    self.ButtonColor = self:Add( "DModelPanel" )

    self.ButtonColor:SetAlpha(255)
    self.ButtonColor:SetColor(self.Color)
    self.ButtonColor:SetSize( 0, 0 )

    self.Button = self:Add( "DButton" )
    self.Button.Font = self.Font
    self.Alpha = vgui.Create("DButton")
    self.Alpha:SetSize(0,0)
    self.Alpha:SetAlpha(self.Color.a)

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

      if not self.editing then
        self.editing = true
        self.txt = self.txt or {}
        self.txt = vgui.Create( "DTextEntry" )

        self.txt:SetSize( 0, 0 )
        self.txt:SetPos(0, 0)
        self.txt:SetFont(self.Font)
        self.txt:SetText("")
        self.txt:SetTextColor(Color(255,255,255))
        self.txt:SetAlpha(0)
        self.txt:SetEditable(true)
        self.txt:SetNumeric( self.Numeric )
        self.txt:SetDrawBackground(false)
        self.txt:SetEnterAllowed( true )
        self.txt:SetUpdateOnType( true )
        self.Text = self.ClickText
        self.txt:MakePopup()
        lobby.keepopen = true
      end

      self.txt.OnValueChange = function(s, string)
        self.Text = self.txt:GetValue()
        self.OnType(self, string)
        self.txt:SetCaretPos( string:len() )
      end

      self.txt.OnEnter = function()
        self.editing = false
        self.OnEnter(self)
        self.txt:Remove()
        lobby.keepopen = false
      end
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
      surface.DrawRect(0, 0, w, h)
      surface.SetTextColor(Color(255,255,255))
      surface.SetFont( self:GetParent().Font )
      self.txtw, self.txth = surface.GetTextSize(self:GetParent().Text)
      surface.SetTextPos( (w/2) - self.txtw/2,(h/2) - self.txth/2 )
      surface.DrawText( self:GetParent().Text )
    end

	end,
  Update = function(self)
    if !self.Button then return end
    self.ButtonColor:SetColor(self.Color)

    self.Button.Font = self.Font
    self.Alpha:SetAlpha(self.Color.a)
    self.Button:SetText("")
    self.Button:SetSize(self:GetWide(),self:GetTall())
    /*
      local alphabut = self.Alpha
    local colorbut = self.ButtonColor
    self.Button.Paint = function(self, w, h)

      surface.SetDrawColor( Color(colorbut:GetColor().r,colorbut:GetColor().g,colorbut:GetColor().b, alphabut:GetAlpha()) )
      surface.DrawRect(0, 0, w, h)
      surface.SetTextColor(Color(255,255,255))
      surface.SetFont( self:GetParent().Font )
      self.txtw, self.txth = surface.GetTextSize(self:GetParent().Text)
      surface.SetTextPos( (w/2) - self.txtw/2,(h/2) - self.txth/2 )
      surface.DrawText( self:GetParent().Text )
    end
    */
  end,
  SetFont = function(self, font)
    self.Font = font
    self:Update()
  end,

  SetText = function(self, txt)
    self.Text = txt
    self.DefText = txt
    self:Update()
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

vgui.Register( "TextEdit", TEXTEDIT, "EditablePanel" )
