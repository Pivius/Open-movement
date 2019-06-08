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
  end,
  SetFont = function(self, font)
    self.Font = font
    self:Update()
  end,

  SetText = function(self, txt)
    self.Text = txt
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

BUTTON = vgui.RegisterTable( BUTTON, "EditablePanel" )

local PANEL = {}

function PANEL:Init()
  local x, y = self:GetPos()

	local w = self:GetWide()
	local h = self:GetTall()

  self.Panel= self:Add( "DFrame" )
  self.Panel:SetPos( 0, 41 )
  self.Panel:SetSize(600, (40+5)*8)
  self.Panel:SetTitle("")
  self.Panel:SetDraggable(false)
  self.Panel:ShowCloseButton( false )
  self.Panel.Paint = function(self, w, h )
    surface.SetDrawColor( Color(15,15,15,200) )
    surface.DrawRect(0, 0, w, h)
  end
  SetFont("Help_Topic", {
    font = "SIMPLIFICA",
    weight = 1000,
    size = 30,
    antialias = true
  })
  SetFont("Help_SubTopic", {
    font = "SIMPLIFICA",
    weight = 1000,
    size = 25,
    antialias = true
  })
  SetFont("Help_Text", {
    font = "MavenPro",
    weight = 552,
    size = 18,
    antialias = true
  })

  self.Bar = self:Add( "EditablePanel" )
  self.Bar:SetPos( 0, 0 )
  self.Bar:SetSize(600, 40)
  self.Bar.Buttons = {}
  self.Page = 1
  self.TotPages = 0
  self.Texts = {}
  self.Topics = {}
  self.Fonts = {}
  self.Color = {}
  self.Ident = {}
  self.Panels = {}
  self.CurCol = Color(255,255,255)
  self.CurFont = GetFont("Help_Topic")
  self.Pos = {}
  self.Line = 0
  self.DidSetCol = false
  self.DidSetFont = false
  self.Prevtxts = {0,0}

  self.Text = vgui.Create("DScrollPanel", self.Panel)
  self.Text:SetSize(600-10, (40+5)*8-20)
  self.Text:SetPos(10,10)
  self.Text.Paint = function(self, w, h )
  end
  local sbar = self.Text:GetVBar()
  function sbar:Paint( w, h )
    surface.SetDrawColor( Color(25,25,25,200) )
    surface.DrawRect(w/2, 0, w/2, h)
  end
  function sbar.btnUp:Paint( w, h )
    surface.SetDrawColor( Color(100,100,100,100) )
    surface.DrawRect(w/2, 0, w/2, h)
  end
  function sbar.btnDown:Paint( w, h )
    surface.SetDrawColor( Color(100,100,100,100) )
    surface.DrawRect(w/2, 0, w/2, h)
  end
  function sbar.btnGrip:Paint( w, h )
    surface.SetDrawColor( Color(50,50,50,200) )
    surface.DrawRect(w/2, 0, w/2, h)
  end

  self.Text.OnVScroll = function(self, iOffset )
    self.offset = iOffset
  end
  self.Text.offsetsmooth = 0
  self.Text.vBarSmooth = 0
  self.Text.offset = 0
  self.Text.Think = function(self)
    self.offsetsmooth = self.offsetsmooth and UT:Lerp(0.1, self.offsetsmooth , self.offset) or self.offset
    self.vBarSmooth = self.vBarSmooth and UT:Lerp(0.2, self.vBarSmooth , self.offset) or self.offset
    self:GetVBar().Scroll = -(self.vBarSmooth)
    --self.VBar:SetPos(0,0)
    self.pnlCanvas:SetPos( 0, self.offsetsmooth )
  end

  self.Text.PerformLayout = function(self )
    local wide = self:GetWide()
    self:Rebuild()
    self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
    --self.VBar:SetSize(0,0)
    if self.VBar.Enabled then wide = wide end-- self.VBar:GetWide() end
    self.pnlCanvas:SetWide(wide)
    self:Rebuild()
  end

end

function PANEL:Reset(hard)

  for k, v in pairs(self.Panels) do
    for _, v in pairs(v) do
      if type(v) == "table" then
        for _, panel in pairs(v) do
          panel:Remove()
        end
      else
        v:Remove()
      end
    end
  end
  self.Text:GetVBar().Scroll = -(0)
  self.Text.pnlCanvas:SetPos( 0, 0 )
  self.CurCol = Color(255,255,255)
  self.CurFont = GetFont("Help_Topic")
  self.Text.offset = 0
  self.smoothoffset = 0
  self.vBarSmooth = 0
  if hard then
    self.Texts = {}
    self.Topics = {}
    self.Fonts = {}
    self.Color = {}
    self.Pos = {}
    self.Ident = {}
    self.TotPages = 0
  end
  self.DidSetCol = false
  self.DidSetFont = false
  self.Line = 0
  self.Prevtxts = {0,0}
end

function PANEL:NewPage(name)
  local ButtonCol = Color(15,15,15,170)
  local ButtonHighCol = Color(255,255,255)
  self.TotPages = self.TotPages+1
  self.Pos[self.TotPages] = 1
  self.Texts[self.TotPages] = {}
  self.Topics[self.TotPages] = {}
  self.Fonts[self.TotPages] = {}
  self.Color[self.TotPages] = {}
  self.Ident[self.TotPages] = {}
  self.Panels[self.TotPages] = {}
  local PageSet = self.TotPages
  local button = vgui.CreateFromTable( BUTTON, self.Bar )
  button:Dock(LEFT)
  button:DockMargin( 0, 0, 1, 0 )
  button:SetSize(75, 40)
  button:SetText(name)

  button:SetColor(ButtonCol)
  button:SetHighlight(ButtonHighCol)
  button.Button.OnClick = function()
    self:Reset()
    self.Page = PageSet
    self:Build()
  end
  table.insert(self.Bar.Buttons, button)
end

local function FirstValueLower(x, list, key, num)
  if !num then
    num = 0
  end
  for k, v in pairs(list) do
    local comp = v
    if key then
      comp = k
    end
    if k > num then
      if k < x then
        if k == #list then
          return k
        else
          return FirstValueLower(x, list, key, k)
        end
      elseif k >= x then
        return num
      end
    end
  end
end

local function AllValueAbove(x, list, key, nums)
  if !nums then
    nums = {0}
  end
  for k, v in pairs(list) do
    local comp = v
    if key then
      comp = k
    end
    if k < nums[#nums] then
      if k > x then
        if k == #list then
          table.insert(nums, k)
          return nums
        else
          table.insert(nums, k)
          return FirstValueLower(x, list, key, nums)
        end
      end
    end
  end
end

function PANEL:Replace(ident, new)
  local ident = table.KeyFromValue( self.Ident[self.Page], ident )
  if self.Fonts[self.Page][ident] then
    self.Fonts[self.Page][ident] = new
  elseif self.Texts[self.Page][ident] then
    if type(self.Panels[self.Page][ident]) == "table" then
      local font = self.Fonts[self.Page][FirstValueLower(ident, self.Fonts[self.Page], true)]
      local oldWrap = wrapText( GetFont(font), self.Texts[self.Page][ident], self:GetWide()-10 )
      local newWrap = wrapText( GetFont(font), new, self:GetWide()-10 )
      for num=1, #oldWrap do
        self.Panels[self.Page][ident][num].Text = ""
      end
      for num=1, #newWrap do
        local text = table.concat( newWrap[num], " ")
        self.Panels[self.Page][ident][num].Text = text
      end
    end
    self.Texts[self.Page][ident] = new
  elseif self.Color[self.Page][ident] then

    self.Color[self.Page][ident] = new
  elseif self.Topics[self.Page][ident] then
    self.Topics[self.Page][ident] = new
  end
end

function PANEL:AddFont(font, ident)
  if ident then
    table.insert(self.Ident[self.TotPages], self.Pos[self.TotPages], ident)
  end
  table.insert(self.Fonts[self.TotPages], self.Pos[self.TotPages], font)
  self.Pos[self.TotPages] = self.Pos[self.TotPages]+1
end

function PANEL:AddText(text, ident)
  if ident then
    table.insert(self.Ident[self.TotPages], self.Pos[self.TotPages], ident)
  end
  table.insert(self.Texts[self.TotPages], self.Pos[self.TotPages], text)
  self.Pos[self.TotPages] = self.Pos[self.TotPages]+1
end

function PANEL:AddColor(col, ident)
  if ident then
    table.insert(self.Ident[self.TotPages], self.Pos[self.TotPages], ident)
  end
  table.insert(self.Color[self.TotPages], self.Pos[self.TotPages], col)
  self.Pos[self.TotPages] = self.Pos[self.TotPages]+1
end

function PANEL:AddTopic(topic, ident)
  self:AddColor(Color(119, 143, 246, 255))
  self:AddFont(GetFont("Help_Topic"))
  if ident then
    table.insert(self.Ident[self.TotPages], self.Pos[self.TotPages]-2, ident)
    table.insert(self.Ident[self.TotPages], self.Pos[self.TotPages]-1, ident)
    table.insert(self.Ident[self.TotPages], self.Pos[self.TotPages], ident)
  end
  table.insert(self.Topics[self.TotPages], self.Pos[self.TotPages], topic)
  self.Pos[self.TotPages] = self.Pos[self.TotPages]+1
end

function PANEL:Build()
  for i=1, self.Pos[self.Page] do
    if !self.DidSetFont then
      surface.SetFont( GetFont("Help_Text") )
    end
    if !self.DidSetCol then
      surface.SetTextColor( 255, 255, 255, 255 )
    end

    if self.Texts[self.Page][i] then
      local font = self.Fonts[self.Page][self.CurFont]
      local wrap = wrapText( GetFont(font), self.Texts[self.Page][i], self:GetWide()-10 )
      self.Panels[self.Page][i] = {}
      for num=1, #wrap do
        local text = table.concat( wrap[num], " ")
        self.Panels[self.Page][i][num] = vgui.Create("EditablePanel", self.Panels[self.Page][i][num])
        local txtx, txty = surface.GetTextSize( text )
        self.Panels[self.Page][i][num]:SetSize(self:GetWide(), txty+1)
        self.Panels[self.Page][i][num]:Dock(TOP)
        self.Panels[self.Page][i][num].Font = GetFont(self.CurFont)
        if self.Panels[self.Page][i][num].Font == nil then
        end
        self.Panels[self.Page][i][num].Text = text
        self.Panels[self.Page][i][num].ColIndex = self.CurCol
        self.Panels[self.Page][i][num].FontIndex = self.CurFont
        local pan = self
        self.Panels[self.Page][i][num].Paint = function(self)
          self.Font = GetFont(pan.Fonts[pan.Page][self.FontIndex])
          self.Color = pan.Color[pan.Page][self.ColIndex]
          --surface.SetTextPos( 10, (self.Prevtxts[2])-2 )
          surface.SetTextPos( 0, 0 )
          surface.SetFont( self.Font )
          --local test = FirstValueLower(i, pan.Color[pan.Page], true)
          surface.SetTextColor( self.Color )
          surface.DrawText( self.Text )
        end
        --self.Prevtxts = {self.Prevtxts[1]+txtx,self.Prevtxts[2]+txty-2}
        --self.Line = self.Line+1
        self.Text:AddItem(self.Panels[self.Page][i][num])
        table.insert(self.Panels[self.Page], self.Panels[self.Page][i][num])
      end
    elseif self.Fonts[self.Page][i] then
      self.DidSetFont = true
      self.CurFont = i
      surface.SetFont( self.Fonts[self.Page][i] )
    elseif self.Topics[self.Page][i] then
      local font = self.Fonts[self.Page][self.CurFont]
      local wrap = wrapText( GetFont(font), self.Topics[self.Page][i], self:GetWide()-10 )
      self.Panels[self.Page][i] = {}
      for num=1, #wrap do
        local text = table.concat( wrap[num], " ")
        self.Panels[self.Page][i][num] = vgui.Create("EditablePanel", self.Panels[self.Page][i][num])
        self.Panels[self.Page][i][num]:Dock(TOP)
        self.Panels[self.Page][i][num]:DockMargin(0,10,0,-2)
        local txtx, txty = surface.GetTextSize( text )
        txty = txty +10
        self.Panels[self.Page][i][num]:SetSize(self:GetWide(), txty)
        self.Panels[self.Page][i][num].ColIndex = self.CurCol
        self.Panels[self.Page][i][num].FontIndex = self.CurFont
        local pan = self
        self.Panels[self.Page][i][num].Paint = function(self)
          self.Font = GetFont(pan.Fonts[pan.Page][self.FontIndex])
          self.Color = pan.Color[pan.Page][self.ColIndex]
          --surface.SetTextPos( 10, (self.Prevtxts[2])+10 )
          surface.SetTextPos( 0, 0 )
          surface.SetFont( self.Font )
          surface.SetTextColor( self.Color )
          surface.DrawText( text )
        end
        --self.Prevtxts = {self.Prevtxts[1]+txtx,self.Prevtxts[2]+txty}
        --self.Line = self.Line+1
        self.Text:AddItem(self.Panels[self.Page][i][num])
        table.insert(self.Panels[self.Page], self.Panels[self.Page][i][num])
      end
    elseif self.Color[self.Page][i] then
      self.DidSetCol = true
      self.CurCol = i
      surface.SetTextColor( self.Color[self.Page][i] )
    end
  end
end
function PANEL:PerformLayout()
	local x, y = self:GetPos()

	local w = self:GetWide()
	local h = self:GetTall()
  self.Panel:SetPos( x, y+41 )
  self.Panel:SetSize(w, h+45)
  self.Bar:SetPos( x, y )
  self.Bar:SetSize(w, 40)
  self.Text:SetSize(w-10, h-45-20)
  self:Reset()

  self:Build()
end

vgui.Register( "TopicPanel", PANEL, "EditablePanel" )
