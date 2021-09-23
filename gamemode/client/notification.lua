queue ={}
notified = false

NotifyBox =
{
	Init = function( self )
    self:SetAlpha( 0, 0 )
    self.show = true
    self.smooth = ScrW()


    self.MessagePanel = self:Add( "DPanel" )
    self.MessagePanel:Dock( FILL )
    self.MessagePanel:DockMargin( 5, 5, 5, 5 )

    self.MessageTitle = self.MessagePanel:Add( "DLabel" )
    self.MessageTitle:Dock( TOP )
    self.MessageTitle:SetTextColor( Color(255,255,255) )
    self.MessageTitle:SetFont("HUD Notification")
    self.MessageTitle:SetContentAlignment( 8 )


    self.MessagePanel.Paint = function(self, w, h)
      if self.type == "normal" then
        surface.SetDrawColor(Color(0, 0, 0, 200))
        surface.DrawRect(0, 0, w, h)
      end
    end



    --self.MessagePanel:SetSize( self.w-25, self.size-25 )
	end,

	Setup = function( self, msg, tp, tm, tbl )

		self.Player = pl

		self:Think( self )
    self.type = tp
    self.msg = msg
    self.time = tm
    self.MessagePanel.type = self.type
    self.MessagePanel:SetWide(250)
    self.MessageTitle.msg = string.Split(self.msg, " ")[1]
    self.MessageTitle:SetText(self.MessageTitle.msg)
    if istable( tbl ) then
      if tbl[1] then
        self.MessageTitle:SetTextColor(tbl[1])
      end
    end
    self.msg = string.Split(self.msg, " ")
    table.remove(self.msg, 1)
    self.lines = wrapText( "HUD Notification", string.Implode(" ", self.msg), self.MessagePanel:GetWide() )
    self.words = 1
    self.Message = {}
    for k, v in pairs(self.lines) do
      local text = {}
      self.Message[k] = self.MessagePanel:Add( "DPanel" )
      --self.Message[k]:SetFont("Scoreboard line")
      --self.Message[k]:SetTextColor( Color(255,255,255) )
      self.Message[k]:Dock( TOP )
      self.Message[k]:SetContentAlignment( 8 )
      self.Message[k].Paint = function(self, w, h)

      end
      for _,txt in pairs(v) do
        self.words = self.words+1
        self.Message[k][_] = self.Message[k]:Add( "DLabel" )
        self.Message[k][_]:SetFont("HUD Notification")
        self.Message[k][_]:SetTextColor( Color(255,255,255) )
        self.Message[k][_]:Dock( LEFT )

        surface.SetFont("HUD Notification")
        local w, h = surface.GetTextSize( txt )
        self.Message[k][_]:SetWide( w+4 )
        self.Message[k][_]:SetContentAlignment( 8 )

        if tbl[self.words] then
          self.Message[k][_]:SetTextColor(tbl[self.words])
        end
        self.Message[k][_]:SetText(txt)

      end
      surface.SetFont("HUD Notification")
      local w, h = surface.GetTextSize( string.Implode(" ", v) )
      self.Message[k]:SetWide( w )

      self.Message[k]:DockMargin( (248/2)-w/2,0,0,-7 )
    end

  end,

  PerformLayout = function( self )
    surface.SetFont("HUD Notification")
    local w, h = surface.GetTextSize( string.Implode(" ", self.lines[1]) ) -- Just to get the height of the text
    self:SetSize( 260, 32+ (h * #self.lines) )
    self:SetPos( ScrW(), ScrH()/1.5 )

  end,

  Show = function( self )
    local x, y = self:GetPos()
    self.smooth = self.smooth and UT:Lerp(0.25, self.smooth , ScrW()-265) or ScrW()-265
    self:SetPos( self.smooth, y )
  end,

  Hide = function( self )
    local x, y = self:GetPos()
    self.smooth = self.smooth and UT:Lerp(0.25, self.smooth , ScrW()) or ScrW()
    self:SetPos( self.smooth, y )
  end,


	Think = function( self )
		local ply = self.Player
    if self.show then
      self:Show()
    else
      self:Hide()
    end
    local time = self.time
    if time then

    end
	end,

	Paint = function( self, w, h )


		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(0, 0, w, h)
    /*
    if self.type == "normal" then
      surface.SetDrawColor(Color(0, 0, 0, 200))
      surface.DrawRect(5, 5, w-10, h-10)
    end*/
	end
}

NotifyBox = vgui.RegisterTable( NotifyBox, "DPanel" )

if ( IsValid( Notification ) ) then
	Notification:Remove()
end

function Notify(msg, type, time, tbl)
  if notified then return end
  notified = true

  Notification = vgui.CreateFromTable( NotifyBox )
  Notification:Setup( msg, type, CurTime() + time, tbl )
  Notification:AlphaTo( 255, 0.1 )
end

function queueNote(msg, type, time, tbl)
  if !tbl then tbl = "normal" end
  local t = {
    ["Message"] = msg,
    ["Type"] = type,
    ["Time"] = time,
    ["Color"] = tbl,
    ["CurTime"] = 9999
  }
  table.insert(queue, t)
end

net.Receive("Notify", function()
  local msg = net.ReadString()
  local type = net.ReadString()
  local time = net.ReadFloat()
  local col = net.ReadTable()
  queueNote(msg, type, time, col)
end)

endd = false

function NotifyThink()

  for i=1, 2 do
    if i == 2 then
        endd = true
    end

    if !endd then
			/*
      queueNote("aaa I'm the best", "normal", 2, {
        [1]=Color(155,255,51),
        [2]=Color(255,0,0),
        [5]=Color(0,255,0),
        [8]=Color(0,0,255),
        [10]=Color(255,0,255),
        [11]=Color(255,255,0),
        [12]=Color(0,255,255)
      })*/
    end
  end

  if #queue > 0 then
    if queue[1]["Time"]+ queue[1]["CurTime"] <= CurTime() and notified == true then

      Notification.show = false
      if timer.Exists( "queueremoval" ) then return end
      timer.Create("queueremoval", 0.5, 1,function()

        table.remove(queue, 1)

        Notification:Remove()
        notified = false
      end)

    end
  elseif #queue <= 0 then
    notified = false
  end

  for k, v in pairs(queue) do
    if k == 1 and !notified then
      queue[1]["CurTime"] = CurTime()
      Notify(v["Message"], v["Type"], v["Time"],v["Color"])

    end

  end

end
hook.Add("Think","Timernshit", NotifyThink)

net.Receive( "Network msg", function( len, pl )
		local args = net.ReadDouble()
		local argvar = {}

		for i = 1, args do
			local ntype = net.ReadType()
			if type(ntype) == "table" and ntype.r and ntype.b and ntype.g then
				table.insert( argvar, ntype )
			elseif type(ntype) == "string" then
				table.insert( argvar, ntype )
			elseif type(ntype) == "Player" then
				table.insert( argvar, ntype )
			else
				table.insert( argvar, util.TypeToString(ntype) )
			end

		end

		chat.AddText( unpack( argvar ) )
	end )
