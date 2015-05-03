if SERVER then
	finish_corner_red, finish_corner_blue = Vector(0,0,0), Vector(0,0,0)
	position = 0

	util.AddNetworkString( "DrawFinish" )
	util.AddNetworkString( "DontDrawFinish" )
	util.AddNetworkString( "UpdateFinishCorners" )

	Finish1st = "Nobody"
	Finish2nd = "Nobody"
	Finish3rd = "Nobody"

	if not file.Exists("dr_map_finishlines", "DATA") then
		file.CreateDir("dr_map_finishlines")
	end

	if file.Exists("dr_map_finishlines/" .. game.GetMap() .. ".txt", "DATA") then
		local corners = util.JSONToTable(file.Read("dr_map_finishlines/" .. game.GetMap() .. ".txt"))
		finish_corner_red = corners["red"]
		finish_corner_blue = corners["blue"]
	end
end

if CLIENT then
	corner_red, corner_blue = Vector(0,0,0), Vector(0,0,0)

	net.Receive( "DrawFinish", function() drawFinish() end)
	net.Receive( "DontDrawFinish", function() dontDrawFinish() end)
	net.Receive( "UpdateFinishCorners", function() updateFinishCorners(net.ReadTable(), ply) end)
end

function setFinishZone(corner, ply)

	print(file.Exists("dr_map_finishlines/" .. game.GetMap() .. ".txt", "DATA"))

	if corner == 0 then
		finish_corner_red = ply:GetEyeTrace().HitPos

		net.Start("UpdateFinishCorners")
			finishvectors = {
				[1] = finish_corner_red,
				[2] = finish_corner_blue
			}
			net.WriteTable(finishvectors)
		net.Broadcast()

		print("Got the first corner for finish")
	else
		finish_corner_blue = ply:GetEyeTrace().HitPos

		net.Start("UpdateFinishCorners")
			finishvectors = {
				[1] = finish_corner_red,
				[2] = finish_corner_blue
			}
			net.WriteTable(finishvectors)
		net.Broadcast()

		print("Got the second corner for finish")
	end

	if SERVER then
		local corners = {
			["red"] = finish_corner_red,
			["blue"] = finish_corner_blue
		}

		if finish_corner_red ~= Vector(0,0,0) and finish_corner_blue ~= Vector(0,0,0) then
				print("Updated map " .. game.GetMap() .. ".txt!")
				file.Write("dr_map_finishlines/" .. game.GetMap() .. ".txt", util.TableToJSON(corners))
		end
	end

end

function drawFinish()
	print("Visualising finish zone, do dr_dontdrawfinish to clear")
	print(corner_red)
	print(corner_blue)
	hook.Add( "HUDPaint", "dr_drawfinish", function()
		cam.Start3D()
			render.SetColorMaterial()
			render.DrawSphere(corner_red, 10, 5, 5, Color(255,0,0,255))
			render.DrawSphere(corner_blue, 10, 5, 5, Color(0,100,255,255))
			render.DrawBox(Vector(0,0,0), Angle(0,0,0,0,0,0), corner_red, corner_blue, Color(0,255,0,100), true)
		cam.End3D()
	end)
end

function updateFinishCorners(corners)
	corner_red = corners[1]
	corner_blue = corners[2]

	print(corner_red)
	print(corner_blue)
end

function dontDrawFinish()
	print("Visualisation cleared")
	hook.Remove("HUDPaint", "dr_drawfinish")
end

concommand.Add("dr_finish_red_corner", function(ply)
	if not ply:IsUserGroup("superadmin") then return false end
	setFinishZone(0, ply)
end)
concommand.Add("dr_finish_blue_corner", function(ply)
	if not ply:IsUserGroup("superadmin") then return false end
	setFinishZone(1, ply)
end)

concommand.Add("dr_drawfinish", function(ply)
	if not ply:IsUserGroup("superadmin") then return false end
	net.Start("DrawFinish")
		finishvectors = {
			[1] = finish_corner_red,
			[2] = finish_corner_blue
		}
		net.WriteTable(finishvectors)
	net.Broadcast()
end)

concommand.Add("dr_dontdrawfinish", function(ply)
	if not ply:IsUserGroup("superadmin") then return false end
	net.Start("DontDrawFinish")
	net.Broadcast()
end)

concommand.Add("dr_printtop3", function() PrintTop3() end)

if SERVER then
	function PlayerCrossFinish(player)

		if GetGlobalInt( "Deathrun_RoundPhase" ) ~= 2 then return false end -- ROUND_ACTIVE

		if player:Team() == TEAM_DEATH then return false end

		local PlayersInArea = ents.FindInBox(finish_corner_red, finish_corner_blue)
		if not table.HasValue(PlayersInArea, player) then return false end

		if table.HasValue(PlayersInArea, player) and position < 3 then

			if player:Nick() == Finish1st || player:Nick() == Finish2nd || player:Nick() == Finish3rd then return false end

			position = position + 1

			if position == 1 then
				Finish1st = player:Nick()
				PrintMessage( HUD_PRINTTALK, player:Name() .. " is the 1st to reach the end!")
			elseif position == 2 then
				Finish2nd = player:Nick()
				PrintMessage( HUD_PRINTTALK, player:Name() .. " is the 2nd to reach the end!")
			else
				Finish3rd = player:Nick()
				PrintMessage( HUD_PRINTTALK, player:Name() .. " is the 3rd to reach the end!")
			end

		end
	end

	function PrintTop3()
		PrintMessage( HUD_PRINTTALK, "Top 3 players who reached the end:")
		PrintMessage( HUD_PRINTTALK, "1st. " .. Finish1st .. ", 2nd. "  .. Finish2nd .. ", 3rd. " .. Finish3rd)
	end

	function ClearTop3()
		if GetGlobalInt( "Deathrun_RoundPhase" ) ~= 3 then return false end-- ROUND_ENDING

		if Finish1st ~= "Nobody" then
			PrintTop3()
		end

		Finish1st = "Nobody"
		Finish2nd = "Nobody"
		Finish3rd = "Nobody"
		position = 0
	end

	hook.Add( "OnRoundSet", "ClearTop3", ClearTop3)
	hook.Add( "PlayerFootstep", "PlayerCrossFinish", PlayerCrossFinish )
end
