local corner_red, corner_blue = Vector(0,0,0), Vector(0,0,0)

function setFinishZone(corner, ply)
	if corner == 0 then
		corner_red = ply:GetEyeTrace().HitPos

		net.Start("UpdateFinishCorners")
			finishvectors = {
				[1] = corner_red,
				[2] = corner_blue
			}
			net.WriteTable(finishvectors)
		net.SendToServer()

		print("Got the first corner for finish")
	else
		corner_blue = ply:GetEyeTrace().HitPos

		net.Start("UpdateFinishCorners")
			finishvectors = {
				[1] = corner_red,
				[2] = corner_blue
			}
			net.WriteTable(finishvectors)
		net.SendToServer()

		print("Got the second corner for finish")
	end
end

function moveCorner(corner, x, y, z)
	local vadd = Vector( x, y, z )

	if corner == "red" then
		corner_red:Add( vadd )
	elseif corner == "blue" then
		corner_blue:Add( vadd )
	end

	net.Start("UpdateFinishCorners")
		local finishvectors = {
			[1] = corner_red,
			[2] = corner_blue
		}
		net.WriteTable(finishvectors)
	net.SendToServer()
end

function drawFinish(finishvectors)
	print("Visualising finish zone, do dr_dontdrawfinish to clear")
	corner_red = finishvectors[1]
	corner_blue = finishvectors[2]
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

function PlayFinishSound()
	surface.PlaySound("garrysmod/content_downloaded.wav")
end

function dontDrawFinish()
	print("Visualisation cleared")
	hook.Remove("HUDPaint", "dr_drawfinish")
end

concommand.Add("dr_finish_red_corner", function(ply)
	if ply:IsUserGroup("superadmin") || ply:SteamID() == "STEAM_0:0:20061521" then setFinishZone(0, ply) end
end)

concommand.Add("dr_finish_blue_corner", function(ply)
	if ply:IsUserGroup("superadmin") || ply:SteamID() == "STEAM_0:0:20061521" then setFinishZone(1, ply) end
end)

concommand.Add("dr_drawfinish", function(ply)
	if ply:IsUserGroup("superadmin") || ply:SteamID() == "STEAM_0:0:20061521" then
		net.Start("DrawFinish")
			finishvectors = {
				[1] = corner_red,
				[2] = corner_blue
			}
			net.WriteTable(finishvectors)
		net.SendToServer()
	end
end)

concommand.Add("dr_finish_corner_move", function( ply, _, args )
	if ply:IsUserGroup("superadmin") || ply:SteamID() == "STEAM_0:0:20061521" then
		for k,v in pairs (args) do
			if k == 1 then continue end
			args[k] = tonumber(v)
		end
		moveCorner(args[1], args[2], args[3], args[4])
	end
end)

net.Receive( "DrawFinish", function() drawFinish(net.ReadTable()) end)
net.Receive( "DontDrawFinish", function() dontDrawFinish() end)
net.Receive( "UpdateFinishCorners", function() updateFinishCorners(net.ReadTable()) end)

net.Receive("CrossedFinish", PlayFinishSound)

net.Receive("PrintTop3", function() 
	local top3 = net.ReadTable()
	local first, second, third
	local gold = Color(255, 255, 0)
	local silver = Color(150, 150, 150)
	local bronze = Color(200, 130, 30)

	if top3[1] ~= nil then first = top3[1]:Nick() else first = "Nobody" end

	if top3[2] ~= nil then second = top3[2]:Nick() else second = "Nobody" end

	if top3[3] ~= nil then third = top3[3]:Nick() else third = "Nobody" end

	chat.AddText( Color( 255, 255, 255 ),  "[FINISHLINE] Top 3 players who reached the end:")
	chat.AddText( "[FINISHLINE] ", gold , "1st. ", first , silver , ", 2nd. "  , second , bronze , ", 3rd. " , third)
end)

net.Receive( "UpdateFinishCorners", function()
	updateFinishCorners(net.ReadTable())
end)

