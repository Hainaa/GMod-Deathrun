net.Receive( "SpawnGhost", function()
	chat.AddText( Color( 255, 255, 100 ), "[GHOST] You have spawned as a ghost. You get noclip for 4 seconds")
end)

net.Receive( "GhostUnableIsAlive", function()
	chat.AddText( Color( 255, 255, 100 ), "[GHOST] You cannot use this command while alive")
end)

net.Receive( "GhostMinCount", function()
	chat.AddText( Color( 255, 255, 100 ), "[GHOST] Not enough players to be a ghost")
end)

net.Receive( "GhostNoclip", function()
	chat.AddText( Color( 255, 255, 100 ), "[GHOST] You have stopped noclipping")
end)

hook.Add("PlayerFootstep", "GhostSilentMovementCS", function( ply, pos, foot, sound, volume, filter )
	if ply:Team() == TEAM_GHOST and ply == LocalPlayer() then
		volume = 0
		return true
	end

	return false
end)