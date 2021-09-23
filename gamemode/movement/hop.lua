function AutoHop(ply, mv, can_auto_hop)
  if !ply:IsOnGround() and can_auto_hop and ply:WaterLevel() <= 1 then
    mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )
  end
end
