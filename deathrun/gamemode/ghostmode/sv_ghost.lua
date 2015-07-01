local PLY = FindMetaTable( "Player" )
local ENTIG = {}

util.AddNetworkString( "SpawnGhost" )
util.AddNetworkString( "GhostUnableIsAlive" )
util.AddNetworkString( "GhostMinCount" )
util.AddNetworkString( "GhostNoclip" )

function PLY:IsGhost()
	if self:Team() == TEAM_GHOST then
		return true
	end

	return false
end

hook.Add("PS_PlayerSpawn", "NakedGhost", function() 
	if self:Team() == TEAM_GHOST then
		return false
	end

	return true
end)

hook.Add("PS_CanPerformAction", "NakedGhostAction", function()
	if self:Team() == TEAM_GHOST then
		return false
	end

	return true
end)

hook.Add("PlayerSay", "BeTheGhost", function( ply, text )

	if table.HasValue( GHOST.ChatCommands, string.lower(text) ) then

		if ply:Alive() and ply:Team() ~= TEAM_GHOST then
			net.Start("GhostUnableIsAlive")
			net.Send(ply)

			return ""
		end

		if #player.GetAll() < GHOST.PlayerMin or #player.GetAll() == 1 then
			net.Start("GhostMinCount")
			net.Send(ply)

			return ""
		end

		ply:SetTeam(TEAM_GHOST)
		ply:Spawn()
		ply:SetCustomCollisionCheck(true)

		net.Start("SpawnGhost")
		net.Send(ply)

		local spawns = ents.FindByClass( "info_player_counterterrorist" )

		if #spawns > 0 then
			local pos = table.Random( spawns ):GetPos()
			ply:SetPos( pos )
			ply:SetMoveType( MOVETYPE_NOCLIP )

			timer.Simple( 1, function()
				if (IsValid(ply) and ply:Alive() and pos) then
					ply:SetPos( pos )
					ply:SetMoveType( MOVETYPE_NOCLIP )
				end
			end )

			timer.Simple( 4, function()
				if (IsValid(ply) and ply:Alive() and pos) then
						ply:SetMoveType( MOVETYPE_WALK )
						net.Start("GhostNoclip")
						net.Send(ply)
				end
			end)
		end	

		return ""
	end
end)

hook.Add("PlayerSpawn", "GhostSpawn", function( ply )

	if ply:Team() == TEAM_GHOST then
		local grey = Color( 100, 100, 100, 0 )

		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		ply:SetColor(grey)

		for _,v in pairs(ENTIG) do
			if IsValid(v) then
				v:SetPreventTransmit(ply, true)
			end
		end

	elseif ply:Team() ~= TEAM_GHOST then
		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:SetColor(Color( 255, 255, 255, 255) )
		ply:SetCustomCollisionCheck(false)

		for _,v in pairs(ENTIG) do
			if IsValid(v) then
				v:SetPreventTransmit(ply, false)
			end
		end
	end

end)

hook.Add("PlayerFootstep", "GhostSilentMovement", function( ply, pos, foot, sound, volume, filter )
	if ply:Team() == TEAM_GHOST then
		volume = 0
		return true
	end

	return false
end)

hook.Add("ShouldCollide", "GhostCollision", function( ent1, ent2 )
	if ent1:IsPlayer() or ent2:IsPlayer() and ent1:IsValid() or ent2:IsValid() then
		--PrintMessage(HUD_PRINTTALK, ent1:GetClass() .. " collided with " .. ent2:GetClass())

		if ent1:GetClass() == "player" and table.HasValue( GHOST.AvoidEntities, ent2:GetClass() ) then
			return false
		end

		if ent2:GetClass() == "player" and table.HasValue( GHOST.AvoidEntities, ent1:GetClass() ) then
			return false
		end

		if ent1:GetClass() == "player" and ent2:GetClass() == "player" then
			return false
		end
	end

	return true
end)


hook.Add("EntityTakeDamage", "GhostGod", function( target, dmginfo)
	if target:IsPlayer() then
		if target:Team() == TEAM_GHOST and target:GetMoveType() == MOVETYPE_NOCLIP then
			dmginfo:SetDamage( 0 )
		end
	end
end)

hook.Add("PlayerUse", "DisallowGhostInteract", function( ply, ent) 
	if ply:Team() == TEAM_GHOST then
		return false
	end

	return true
end)

hook.Add("PostCleanupMap", "GhostHideFromView", function()
	for _,v in pairs(GHOST.AvoidEntities) do
		for _,v2 in pairs(ents.FindByClass( v )) do
			table.insert(ENTIG, v2)
		end
	end
end)