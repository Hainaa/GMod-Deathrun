util.AddNetworkString( "DR_PointMessage" )

local mapendreach = false
local mapmult

function CheckPlayers()
	if #player.GetAll() < DRPOINTS.MinPlayers then 
		PrintMessage(HUD_PRINTTALK, "[DRPOINTS] Not enough players to reward points in events")
		return true 
	end
end

function PointMessage(ply, val, reason)
	if not ply:IsValid() then return false end

	net.Start("DR_PointMessage")
		net.WriteInt(val, 10)
		net.WriteString(reason)
	net.Send(ply)
end

function DynamicMult(rate, value, min, max)
	return math.Clamp(math.Truncate(value + (rate - rate * (value - 0.5)/max), 2), min, max)
end

hook.Add("DR_CrossFinish", "GivePointsAtEnd", function(ply, pos)
	if CheckPlayers() then 
		return false 
	end

	mapendreach = true

	if pos == 1 then
		DRA_DB.DRA_set_last_beat(ply)
		DRA_DB.DRA_ply_mapend(ply)
	end

	DRA_DB.DRA_ply_mod_stats(ply, DRA_DB.ReachedEnd, nil)

	if pos > #DRPOINTS.PositionPoints then
		ply:PS_GivePoints(math.Round(DRPOINTS.Default * DRA_DB.DRA_map_get_mult_modify()))

		PointMessage(ply, DRPOINTS.Default * DRA_DB.DRA_map_get_mult_modify(), "reaching the end!")

		return true
	end

	ply:PS_GivePoints(math.Round(DRPOINTS.PositionPoints[pos] * DRA_DB.DRA_map_get_mult_modify()))
	if pos == 1 then
		PointMessage(ply, math.Round(DRPOINTS.PositionPoints[pos] * DRA_DB.DRA_map_get_mult_modify()), "coming 1st!")
	elseif pos == 2 then
		PointMessage(ply, math.Round(DRPOINTS.PositionPoints[pos] * DRA_DB.DRA_map_get_mult_modify()), "coming 2nd!")
	elseif pos == 3 then
		PointMessage(ply, math.Round(DRPOINTS.PositionPoints[pos] * DRA_DB.DRA_map_get_mult_modify()), "coming 3rd!")
	end

end)

hook.Add("PlayerDeath", "GivePointsKill", function(vic, inf, att)
	if CheckPlayers() then 
		return false
	end
	
	if not att:IsValid() or not att:IsPlayer() then return false end
	if vic == att then return false end

	if att:Team() == TEAM_RUNNER then
		att:PS_GivePoints(math.Round(DRPOINTS.DeathKill * DRA_DB.DRA_map_get_mult_modify()))
		PointMessage(att, math.Round(DRPOINTS.DeathKill * DRA_DB.DRA_map_get_mult_modify()), "killing a death!")
	elseif att:Team() == TEAM_DEATH then
		att:PS_GivePoints(math.Round(DRPOINTS.RunnerKill * DRA_DB.DRA_map_get_mult_modify()))
		PointMessage(att, math.Round(DRPOINTS.RunnerKill * DRA_DB.DRA_map_get_mult_modify()), "killing a runner!")
	end
end)

hook.Add("OnRoundSet", "MapPlayerData", function(round, winner)
	if CheckPlayers() then 
		return false
	end

	if round == ROUND_PREPARING then
		DRA_DB.DRA_map_add_timesplayed()
		PrintMessage(HUD_PRINTTALK, "[DRPOINTS] The map reward multiplier is now: " .. tostring(DRA_DB.DRA_map_get_mult_modify()))

		for k, ply in pairs(player.GetAll()) do
			DRA_DB.DRA_ply_mod_stats(ply, DRA_DB.RoundsPlayed, nil)
		end
	end
end)

hook.Add("DR_WinningTeam", "GiveWinningTeamPoints", function(winteam)
	if CheckPlayers() then 
		return false
	end

	sql.Begin()

	if mapendreach then
		mapendreach = false
		DRA_DB.DRA_map_set_mult_modify(DRA_DB.DRA_map_get_mult_modify() / DRPOINTS.WinDecayRate)
		DRA_DB.DRA_map_add_endreach()
	else
		if winteam ~= TEAM_RUNNER then
			DRA_DB.DRA_map_set_mult_modify(DynamicMult(DRPOINTS.LoseGrowthRate, DRA_DB.DRA_map_get_mult_modify(), DRPOINTS.PointMultMin, DRPOINTS.PointMultMax))
		end
	end

	if winteam == TEAM_RUNNER then
		DRA_DB.DRA_map_add_winlost(true)
		for k, ply in pairs(team.GetPlayers(TEAM_RUNNER)) do
			DRA_DB.DRA_ply_mod_stats(ply, DRA_DB.WonRunner, nil)
		end

		for k, ply in pairs(team.GetPlayers(TEAM_DEATH)) do
			print(ply:Name() .. " lost as death")
			DRA_DB.DRA_ply_mod_stats(ply, DRA_DB.LostDeath, nil)
		end
	else
		DRA_DB.DRA_map_add_winlost(false)
		for k, ply in pairs(team.GetPlayers(TEAM_RUNNER)) do
			DRA_DB.DRA_ply_mod_stats(ply, DRA_DB.LostRunner, nil)
		end

		for k, ply in pairs(team.GetPlayers(TEAM_DEATH)) do
			print(ply:Name() .. " won as death")
			DRA_DB.DRA_ply_mod_stats(ply, DRA_DB.WonDeath, nil)
		end
	end

	for k, ply in pairs(player.GetAll()) do
		if ply:Alive() and ply:Team() == winteam then
			ply:PS_GivePoints(math.Round(DRPOINTS.WinningTeam * 2))
			PointMessage(ply, math.Round(DRPOINTS.WinningTeam * 2), "being alive and in the winning team!")
		elseif ply:Team() == TEAM_DEATH || ply:Team() == TEAM_RUNNER then
			ply:PS_GivePoints(math.Round(DRPOINTS.WinningTeam))
			PointMessage(ply, math.Round(DRPOINTS.WinningTeam), "for playing the round!")
		end
	end

	sql.Commit()
end)

