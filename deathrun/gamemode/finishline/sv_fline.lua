local finish = {}
local finish_corner_red, finish_corner_blue = Vector(0,0,0), Vector(0,0,0)
local position = 0

util.AddNetworkString( "DrawFinish" )
util.AddNetworkString( "DontDrawFinish" )
util.AddNetworkString( "UpdateFinishCorners" )
util.AddNetworkString( "CrossedFinish" )
util.AddNetworkString( "PrintTop3" )
util.AddNetworkString( "RequestFinishCorners" )

if not file.Exists("dr_map_finishlines", "DATA") then
	file.CreateDir("dr_map_finishlines")
end

if file.Exists("dr_map_finishlines/" .. game.GetMap() .. ".txt", "DATA") then
	local corners = util.JSONToTable(file.Read("dr_map_finishlines/" .. game.GetMap() .. ".txt"))
	finish_corner_red = corners["red"]
	finish_corner_blue = corners["blue"]
end

function setFinishZone()
	print(file.Exists("dr_map_finishlines/" .. game.GetMap() .. ".txt", "DATA"))

	local corners = {
		["red"] = finish_corner_red,
		["blue"] = finish_corner_blue
	}

	if finish_corner_red ~= Vector(0,0,0) and finish_corner_blue ~= Vector(0,0,0) then
			print("Updated map " .. game.GetMap() .. ".txt!")
			file.Write("dr_map_finishlines/" .. game.GetMap() .. ".txt", util.TableToJSON(corners))
	end
end

function updateFinishCorners(corners)
	finish_corner_red = corners[1]
	finish_corner_blue = corners[2]

	setFinishZone()

	print(finish_corner_red)
	print(finish_corner_blue)
end

function PlaySoundFinish()
	net.Start("CrossedFinish")
	net.Broadcast()
end

function PlayerCheckFinish(_, player)
	if player:IsPlayer() and player:Alive() then
		if player:Team() == TEAM_GHOST then
			local spawns = ents.FindByClass( "info_player_counterterrorist" )

			if #spawns > 0 then
				local pos = table.Random( spawns ):GetPos()
				player:SetPos( pos )

				timer.Simple( 1, function()
					if (IsValid(player) and player:Alive() and pos) then
						player:SetPos( pos )
					end
				end )
			end	

			return false
		end

		if player:Team() ~= TEAM_RUNNER then return false end

		if table.HasValue( finish, player ) then return false end
		if position > 3 then return false end

		position = position + 1

		if position == 1 then
			PrintMessage( HUD_PRINTTALK, "[FINISHLINE] " .. player:Name() .. " is the 1st to reach the end!")
			finish[position] = player
			PlaySoundFinish()
		elseif position == 2 then
			PrintMessage( HUD_PRINTTALK, "[FINISHLINE] " .. player:Name() .. " is the 2nd to reach the end!")
			finish[position] = player
			PlaySoundFinish()
		else
			PrintMessage( HUD_PRINTTALK, "[FINISHLINE] " .. player:Name() .. " is the 3rd to reach the end!")
			finish[position] = player
			PlaySoundFinish()
		end
	end
end

function PlayerCrossFinish()
	local hasPlayers = false

	if GetGlobalInt( "Deathrun_RoundPhase" ) == 2 then -- ROUND_ACTIVE
		local PlayersInArea = ents.FindInBox(finish_corner_red, finish_corner_blue)

		for _,v in pairs(PlayersInArea) do
			if v:IsPlayer() then
				hasPlayers = true
				break
			end
		end

		if position < 3 and hasPlayers then
			table.ForEach(PlayersInArea, PlayerCheckFinish)
		end

		hasPlayers = false
	end
end

concommand.Add("dr_dontdrawfinish", function(ply)
	if not ply:IsUserGroup("superadmin") || ply:SteamID() == "STEAM_0:0:20061521" then return false end
	net.Start("DontDrawFinish")
	net.Broadcast()
end)

net.Receive( "UpdateFinishCorners", function() updateFinishCorners(net.ReadTable()) end)

net.Receive( "DrawFinish", function()
	local finishvectors = {
		[1] = finish_corner_red,
		[2] = finish_corner_blue
	}

	net.Start("DrawFinish")
		net.WriteTable(finishvectors)
	net.Broadcast()
end)

hook.Add( "OnRoundSet", "ClearTop3", function(round, winner)
	if table.Count(finish) > 0 and round == ROUND_ENDING then

		if finish[1] ~= nil then first = finish[1]:Nick() else first = "Nobody" end

		if finish[2] ~= nil then second = finish[2]:Nick() else second = "Nobody" end

		if finish[3] ~= nil then third = finish[3]:Nick() else third = "Nobody" end

		net.Start("PrintTop3")
			net.WriteTable(finish)
		net.Broadcast()

		table.Empty(finish)

		position = 0

	end
end )

hook.Add( "Think", "PlayerCrossFinish", PlayerCrossFinish )