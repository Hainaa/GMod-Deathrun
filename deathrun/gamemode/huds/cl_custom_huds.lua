local clamp = math.Clamp

function HUDList()
	local huds = {
		"center",
		"minimal",
		"default",
		"nohud",
		"circularcenter"
	}

	return huds
end

include ( "cl_hud_funcs.lua" )

function center_hud(ply, roundtime)
	-- Health bar
	local hw, hh, border = 204, 30, 2
	local hy = ScrH() - 50
	local hx = (ScrW()/2) - hw/2

	draw.RoundedBox( 0, hx, hy, hw, hh, Color( 44, 44, 44, 175 ) )
	draw.RoundedBox( 0, hx + border, hy + border, hw - border*2, hh - border*2, Color( 180, 80, 80, 255 ) )
	local thp = ply:Alive() and ply:Health() or 0
	local hp = thp
	if hp > 0 then
		hp = ( hw - border*2 ) * ( math.Clamp(ply:Health(),0,100)/100)
		draw.RoundedBox( 0, hx + border, hy + border, hp, hh - border*2, Color( 80, 180, 60, 255 ) )
	end

	draw.AAText( tostring( thp > 999 and "dafuq" or math.max(thp, 0) ), "Deathrun_SmoothBig", ScrW()/2, hy - 3, Color(255,255,255,255), TEXT_ALIGN_CENTER )

	-- Speed meter
	local sy = ScrH() - 50 - hh
	local speed = math.Round(LocalPlayer():GetVelocity():Length());

	draw.RoundedBox( 0, hx, sy, hw, hh/2, Color( 44, 44, 44, 175 ) )
	draw.RoundedBox( 0, hx + border, sy + border, hw - border*2, hh/2 - border*2, Color( 80, 80, 80, 255 ) )
	if speed > 0 then
		local speedometer = ( hw - border*2 ) * ( math.Clamp(speed,0,900)/900)
		draw.RoundedBox( 0, hx + border, sy + border, speedometer, hh/2 - border*2, Color( 80, 80, 180, 255 ) )
	end

	draw.AAText( speed, "Deathrun_Smooth", ScrW()/2, sy - 3, Color(255,255,255,255), TEXT_ALIGN_CENTER )


	-- Round timer
	surface.SetFont( "Deathrun_SmoothBig" )
	local rt = string.ToMinutesSeconds(roundtime)
	local ttw, _ = surface.GetTextSize( rt )

	local tw = hw/2 + 5
	local rtx = (ScrW()/2) - ttw/2;
	
	draw.WordBox( 4, rtx, 50, rt, "Deathrun_SmoothBig", Color( 44, 44, 44, 200 ), Color( 255, 255, 255, 255 ) )
end

function minimal_hud(ply, roundtime)
	-- Health bar
	local hw, hh, border = 102, 15, 2
	local hy = ScrH()/3 + 50
	local hx = (ScrW()/2) - hw/2

	local speed = math.Round(LocalPlayer():GetVelocity():Length());
	draw.AAText( speed, "Deathrun_Smooth", ScrW()/2, ScrH()/3 + 100, Color(255,255,255,100), TEXT_ALIGN_CENTER )

	draw.RoundedBox( 0, hx, hy, hw, hh, Color( 44, 44, 44, 175 ) )
	draw.RoundedBox( 0, hx + border, hy + border, hw - border*2, hh - border*2, Color( 180, 80, 80, 100 ) )
	local thp = ply:Alive() and ply:Health() or 0
	local hp = thp
	if hp > 0 then
		hp = ( hw - border*2 ) * ( math.Clamp(ply:Health(),0,100)/100)
		draw.RoundedBox( 0, hx + border, hy + border, hp, hh - border*2, Color( 80, 180, 60, 100 ) )
	end


	-- Round timer
	surface.SetFont( "Deathrun_Smooth" )
	local rt = string.ToMinutesSeconds(roundtime)
	local ttw, _ = surface.GetTextSize( rt )

	local tw = hw/2 + 5
	local rtx = ScrW()/2 - ttw/2 - 4;
	
	draw.WordBox( 4, rtx, ScrH()/3, rt, "Deathrun_Smooth", Color( 44, 44, 44, 50 ), Color( 255, 255, 255, 100 ) )
end

function default_hud(ply, roundtime)
	local hy = ScrH() - 35
	local hx, hw, hh, border = 5, 204, 30, 2

	draw.RoundedBox( 0, hx, hy, hw, hh, Color( 44, 44, 44, 175 ) )
	draw.RoundedBox( 0, hx + border, hy + border, hw - border*2, hh - border*2, Color( 180, 80, 80, 255 ) )
	local thp = ply:Alive() and ply:Health() or 0
	local hp = thp
	if hp > 0 then
		hp = ( hw - border*2 ) * ( math.Clamp(ply:Health(),0,100)/100)
		draw.RoundedBox( 0, hx + border, hy + border, hp, hh - border*2, Color( 80, 180, 60, 255 ) )
	end

	draw.AAText( tostring( thp > 999 and "dafuq" or math.max(thp, 0) ), "Deathrun_SmoothBig", hx + 5, hy - 3, Color(255,255,255,255), TEXT_ALIGN_LEFT )

	-- Speed meter
	local sy = hy - hh
	local speed = math.Round(LocalPlayer():GetVelocity():Length());

	draw.RoundedBox( 0, hx, sy, hw, hh, Color( 44, 44, 44, 175 ) )
	draw.RoundedBox( 0, hx + border, sy + border, hw - border*2, hh - border*2, Color( 80, 80, 80, 255 ) )
	if speed > 0 then
		local speedometer = ( hw - border*2 ) * ( math.Clamp(speed,0,900)/900)
		draw.RoundedBox( 0, hx + border, sy + border, speedometer, hh - border*2, Color( 80, 80, 180, 255 ) )
	end

	draw.AAText( speed, "Deathrun_SmoothBig", hx + 5, sy - 3, Color(255,255,255,255), TEXT_ALIGN_LEFT )

	surface.SetFont( "Deathrun_SmoothBig" )
	local rt = string.ToMinutesSeconds(roundtime)
	local ttw, _ = surface.GetTextSize( rt )

	local tw = hw/2 + 5
	draw.WordBox( 4, tw - ttw/2, sy - 45, rt, "Deathrun_SmoothBig", Color( 44, 44, 44, 200 ), Color( 255, 255, 255, 255 ) )
end

function circularcenter_hud(ply, roundtime)
	local x, y = ScrW()/2, ScrH()/4 * 3.5
	DrawCircle(60, x, y, Color (0, 0, 0, 100))

	-- Speed meter
	local speed = math.Round(LocalPlayer():GetVelocity():Length());
	--draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
	if speed > 0 then
		local speedometer = -180 * ( math.Clamp(speed,0,900)/900 )
		draw.Arc( x, y, 60, 10, 90 + speedometer, 90 + math.abs(speedometer), 0, Color( 51, 153, 255, 155 ))
	end
	surface.SetFont( "Deathrun_Smooth" )
	local _, sph = surface.GetTextSize(speed)
	draw.AAText( speed, "Deathrun_Smooth", x, y - 65, Color(255,255,255,255), TEXT_ALIGN_CENTER )

	-- Health meter
	--DrawCircle(50, x, y, Color(180, 80, 80, 255))
	local thp = ply:Alive() and ply:Health() or 0
	local hp = thp
	if hp > 0 then
		hp = -180 * ( math.Clamp(ply:Health(),0,100)/100)
		draw.Arc( x, y, 50, 50, 90 + hp, 90 + math.abs(hp), 0, Color( 80, 180, 60, 155 ))
	end

	draw.AAText( tostring( thp > 999 and "dafuq" or math.max(thp, 0) ), "Deathrun_SmoothBig", x, y, Color(255,255,255,255), TEXT_ALIGN_CENTER )

	-- Round timer
	surface.SetFont( "Deathrun_Smooth" )
	local rt = string.ToMinutesSeconds(roundtime)
	local ttw, tth = surface.GetTextSize( rt )

	local rtx = x - ttw/2 - 4;
	local rty = y - 30;
	
	draw.WordBox( 4, rtx, rty, rt, "Deathrun_Smooth", Color( 44, 44, 44, 50 ), Color( 255, 255, 255, 255 ) )
end

function nohud_hud(ply, roundtime)

end