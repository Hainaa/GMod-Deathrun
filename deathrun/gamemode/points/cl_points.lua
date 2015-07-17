net.Receive( "DR_PointMessage", function() 
	chat.AddText( "[DRPOINTS] " , Color(150, 255, 100), "You have received " .. net.ReadInt(10) .. " points for " .. net.ReadString())
end)