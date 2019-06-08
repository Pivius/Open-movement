local BUTTON =
{

  Init = function( self )
    self.Font               = "Trebuchet24"
    self.Text               = ""
    self.StartTime          = CurTime()
    self.Color              = Color(0,0,0,0)
    self.Highlight          = Color(255,255,255,250)
    self.Hover              = Color(0,0,0,100)
    self.Cur_Color          = Color(0,0,0)
    self.Init_Color         = Color(0,0,0,0)
    self.End_Color          = Color(0,0,0,0)
    self.Color_Time         = 0.2

    self.Txt_Color          = Color(255,255,255,255)
    self.Txt_Highlight      = Color(255,255,255,255)
    self.Txt_Hover          = Color(255,255,255,255)
    self.Txt_Cur_Color      = Color(0,0,0)
    self.Txt_Init_Color     = Color(0,0,0,0)
    self.Txt_End_Color      = Color(255,255,255,255)
    self.Txt_Color_Time     = 0.2


    self.Color_Fraction     = 0
    self.Txt_Color_Fraction = 0


    self.Button = self:Add( "DButton" )
    self.Button.Font = self.Font

    self.Button:SetText("")
    self.Button:SetSize(self:GetWide(),self:GetTall())
    --self.Button:Dock(TOP)
    self.Button.OnClick = function()
    end
    self.Button.DoClick = function()
      self.Button.OnClick()
      self:SetColor(self.Highlight, self.Txt_Highlight)
      self:ColorTo(self.Color, self.Color_Time, self.Txt_Color, self.Txt_Color_Time)
    end
    self.Button:SetAlpha(255)
    self.Button.OnCursorEntered = function()
      self:ColorTo(self.Hover, self.Color_Time, self.Txt_Hover, self.Txt_Color_Time)
    end

    self.Button.OnCursorExited = function()
      self:ColorTo(self.Color, self.Color_Time, self.Txt_Color, self.Txt_Color_Time)
    end

    self.Button.Paint = function(s, w, h)

      surface.SetDrawColor( self.Cur_Color )
      surface.DrawRect(0, 0, w, h)
      surface.SetTextColor( self.Txt_Cur_Color )
      surface.SetFont( self.Font )
      s.txtw, s.txth = surface.GetTextSize(self.Text)
      surface.SetTextPos( (w/2) - s.txtw/2,(h/2) - s.txth/2 )
      surface.DrawText( self.Text )
    end
    self.Button.Think = function()
      if !self.Cur_Color:Equals(self.End_Color, 2) then
        self.Color_Fraction = math.TimeFraction( self.StartTime, self.StartTime + self.Color_Time, CurTime() )
        self.Cur_Color = util.Color.Lerp(self.Color_Fraction, self.Init_Color, self.End_Color)

      end

      if !self.Txt_Cur_Color:Equals(self.Txt_End_Color, 2) then
        self.Txt_Color_Fraction = math.TimeFraction( self.StartTime, self.StartTime + self.Txt_Color_Time, CurTime() )
        self.Txt_Cur_Color = util.Color.Lerp(self.Txt_Color_Fraction, self.Txt_Init_Color, self.Txt_End_Color)
      end
    end
    print(self.Color)
    self:ColorTo(self.Color, 0.1, self.Txt_Color, 0.1)
	end,

  ColorTo = function(self, col, time, txtcol, txttime)
    assert(IsColor(col), "First argument has to be a color!")
    self.Init_Color = self.Cur_Color

    self.End_Color = col
    self.StartTime = CurTime()
    if !time then return end
    assert(isnumber(time), "Second argument has to be a number!")
    self.Color_Time = time
    if !txtcol then return end
    assert(IsColor(txtcol), "Third argument has to be a color!")
    self.Txt_Init_Color = self.Txt_Cur_Color
    self.Txt_End_Color = txtcol
    if !txttime then return end
    assert(isnumber(txttime), "Fourth argument has to be a number!")
    self.Txt_Color_Time = time
  end,

  Update = function(self)
    if !self.Button then return end
    self.End_Color = self.Cur_Color
    self.Txt_End_Color = self.Txt_Cur_Color
    self.Button.Font = self.Font
    self.Button:SetText("")
    self.Button:SetSize(self:GetWide(),self:GetTall())
  end,
  SetFont = function(self, font)
    self.Font = font
    self:Update()
  end,

  SetText = function(self, txt)
    self.Text = txt
    self:Update()
  end,

  SetColor = function(self, col, txt_col)
    self.Cur_Color = col
    if txt_col then
      self.Txt_Cur_Color = col
    end
    self:Update()
  end,

  SetHighlight = function(self, h, txt_h)
    self.Highlight = h
    if txt_h then
      self.Txt_Highlight = h
    end
  end,

  SetHover = function(self, h, txt_h)
    self.Hover = h
    if txt_h then
      self.Txt_Hover = h
    end
  end,

	Paint = function( self, w, h )
	end,

  Think = function( self, w, h )
  end
}

vgui.Register( "Custom_Button", BUTTON, "EditablePanel" )
