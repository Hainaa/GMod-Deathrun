if SERVER then return end

local scoreboard
local dlist

local hostname_w, hostname_h
local function ScoreboardPaint( panel, w, h )


	draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 50 ) )

end

local function GetPlayerIcon( muted )

	if muted then
		return "icon16/sound_mute.png"
	end

	return "icon16/sound.png"

end

local function isUlxAdmin( ply )
	local adminGroups = {
		"DonatorMod",
		"Owner",
		"head_mod",
		"superadmin",
		"moderator",
		"admin",
		"trial_mod",
		"dev",
		"Co-Owner"
	}

	for _, v in pairs(adminGroups) do
		if ply:IsUserGroup(v) then return true end
	end

	return false
end

local function CreatePlayer( ply )

	local pan = vgui.Create( "DPanel" )
	pan:SetSize( 0, 22 )
	pan.UseMat = GAMEMODE:GetScoreboardIcon( ply ) or hook.Call( "GetScoreboardIcon", nil, ply ) or false
	if pan.UseMat then
		pan.UseMat = Material(pan.UseMat)
	end
	pan.Paint = function( self, w, h )
		if not IsValid(ply) then self:Remove() return end
		if not self.TeamColor then
			self.TeamColor = Color( 77, 77, 77, 250 )
			self.NickColor = GAMEMODE:GetScoreboardNameColor( ply ) or hook.Call( "GetScoreboardNameColor", nil, ply ) or Color( 255, 255, 255, 255 )
			surface.SetFont( "Deathrun_Smooth" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
		end
		h = h - 2

		if ply:SteamID() == "STEAM_0:0:20061521" then
			draw.RoundedBox( 4, 0, 2, w, h, Color(math.random(0,100), math.random(100,150), math.random(200,255), 255) )
			draw.AAText( ply:Nick() .. " - I like to move fast", "Deathrun_Smooth", 2 + 16 + 4, h/2 - self.maxH/2 + 2, Color(255, 255, 255, 255) )
		else
			draw.RoundedBox( 4, 0, 2, w, h, self.TeamColor )
			draw.AAText( ply:Nick(), "Deathrun_Smooth", 2 + 16 + 4, h/2 - self.maxH/2 + 2, self.NickColor )
		end

		if self.UseMat then
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			surface.SetMaterial( self.UseMat )
			surface.DrawTexturedRect( w - 40  - 30, 4, 16, 16 )
			if not self._hButton or self._lastW != w then
				self._hButton = true
				self._lastW = w
				if ply:SteamID() == "STEAM_0:1:38699491" then -- Please don't change this.
					local btn = vgui.Create( "DButton", pan )
					btn:SetSize( 16, 16 )
					btn.Paint = function() end
					btn.DoClick = function() end
					btn:SetText("")
					btn:SetTooltip( ply:Nick().." made this gamemode!" )
					btn:SetPos( w - 18 - 30, 4, 16, 16 )
				end
			end
		end

		draw.AAText( ply:Ping(), "Deathrun_Smooth", w - 5, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )

	end

	local icon, mute

	if ply ~= LocalPlayer() then
		local mute = vgui.Create( "DButton", pan )
		mute:SetText( "" )
		mute:SetSize( 20, 20 )
		mute:SetPos( dlist:GetWide() - 55, 4 )
		mute.DoClick = function()

			if not IsValid(ply) then return end
			local muted = ply:IsMuted()
			ply:SetMuted(not muted)
			icon:SetImage( GetPlayerIcon(not muted) )

		end

		mute.Paint = function( self, w, h )
			if not IsValid(ply) then self:Remove() return end
			surface.SetDrawColor(0,0,0,0)
			surface.DrawRect( 0, 0, w, h )
			if  dlist:GetWide() != 0 then
				icon:SetPos( mute:GetWide() - 20, 0 )
			end
		end

		icon = vgui.Create( "DImage", mute )
		icon:SetSize( 16, 16 )
		icon:SetPos( dlist:GetWide() - 55, 4 )
		icon:SetImage( GetPlayerIcon( ply:IsMuted() ) )
	end

	local ava = vgui.Create( "AvatarImage", pan )
	ava:SetPlayer( ply, 16 )
	ava:SetSize( 16, 16 )
	ava:SetPos( 2, 4 )

	local btn = vgui.Create( "DButton", pan )
	btn:SetSize( 16, 16 )
	btn:SetPos( 2, 4 )
	btn:SetText("")
	btn.Paint = function() end
	btn.DoClick = function()

		if not IsValid(ply) then return end
		ply:ShowProfile()

	end

	-- ULX ADMIN MENU

	btn.DoRightClick = function()

		if not isUlxAdmin(LocalPlayer()) then return false end

		local ulxMenu = DermaMenu() 		-- Is the same as vgui.Create( "DMenu" )

		local plyNick = ply:Nick()
		local plyID = ply:SteamID()

		local userHeading = ulxMenu:AddOption( plyNick )
		userHeading:SetIcon( "icon16/user.png" )
		userHeading.DoClick = function()
			chat.AddText(plyNick .. ": " .. plyID )
		end

		ulxMenu:AddSpacer()

		local ulxSlay = ulxMenu:AddOption( "Slay" )
		ulxSlay:SetIcon( "icon16/cross.png" )
		ulxSlay.DoClick = function()
			RunConsoleCommand("ulx", "slay", plyNick)
		end

		local ulxStrip = ulxMenu:AddOption( "Strip Weapons" )
		ulxStrip:SetIcon( "icon16/cross.png" )
		ulxStrip.DoClick = function()
			RunConsoleCommand("ulx", "strip", plyNick)
		end

		local ulxMuteMenu = ulxMenu:AddSubMenu( "Mute / Unmute" )
		local ulxMute = ulxMuteMenu:AddOption( "Mute" )
		ulxMute:SetIcon( "icon16/cross.png" )
		ulxMute.DoClick = function()
			RunConsoleCommand("ulx", "mute", plyNick)
		end
		local ulxUnmute = ulxMuteMenu:AddOption( "Unmute" )
		ulxUnmute:SetIcon( "icon16/tick.png" )
		ulxUnmute.DoClick = function()
			RunConsoleCommand("ulx", "unmute", plyNick)
		end

		local ulxGagMenu = ulxMenu:AddSubMenu( "Gag / Ungag" )
		local ulxGag = ulxGagMenu:AddOption( "Gag" )
		ulxGag:SetIcon( "icon16/cross.png" )
		ulxGag.DoClick = function()
			RunConsoleCommand("ulx", "gag", plyNick)
		end
		local ulxUngag = ulxGagMenu:AddOption( "Ungag" )
		ulxUngag:SetIcon( "icon16/tick.png" )
		ulxUngag.DoClick = function()
			RunConsoleCommand("ulx", "ungag", plyNick)
		end

		local ulxFreezeMenu = ulxMenu:AddSubMenu( "Freeze / Unfreeze" )
		local ulxFreeze = ulxFreezeMenu:AddOption( "Freeze" )
		ulxFreeze:SetIcon( "icon16/cross.png" )
		ulxFreeze.DoClick = function()
			RunConsoleCommand("ulx", "freeze", plyNick)
		end
		local ulxUnfreeze = ulxFreezeMenu:AddOption( "Unfreeze" )
		ulxUnfreeze:SetIcon( "icon16/tick.png" )
		ulxUnfreeze.DoClick = function()
			RunConsoleCommand("ulx", "unfreeze", plyNick)
		end

		local ulxTeleMenu = ulxMenu:AddSubMenu( "Goto / Bring" )
		local ulxGoto = ulxTeleMenu:AddOption( "Go to" )
		ulxGoto:SetIcon( "icon16/user_go.png" )
		ulxGoto.DoClick = function()
			RunConsoleCommand("ulx", "goto", plyNick)
		end
		local ulxBring = ulxTeleMenu:AddOption( "Bring" )
		ulxBring:SetIcon( "icon16/user_go.png" )
		ulxBring.DoClick = function()
			RunConsoleCommand("ulx", "bring", plyNick)
		end

		local ulxKick = ulxMenu:AddOption( "Kick" )
		ulxKick:SetIcon( "icon16/user_delete.png" )
		ulxKick.DoClick = function()
			RunConsoleCommand("ulx", "kick", plyNick)
		end

		local ulxBanMenu = ulxMenu:AddSubMenu( "Ban" )
		local banOption1 = ulxBanMenu:AddOption( "5 minutes" )
		banOption1:SetIcon( "icon16/user_delete.png" )
		banOption1.DoClick = function()
			RunConsoleCommand("ulx", "ban", 5)
		end

		local banOption2 = ulxBanMenu:AddOption( "1 hour" )
		banOption2:SetIcon( "icon16/user_delete.png" )
		banOption2.DoClick = function()
			RunConsoleCommand("ulx", "ban", 60)
		end

		local banOption3 = ulxBanMenu:AddOption( "1 day" )
		banOption3:SetIcon( "icon16/user_delete.png" )
		banOption3.DoClick = function()
			RunConsoleCommand("ulx", "ban", 1440)
		end

		local banOption4 = ulxBanMenu:AddOption( "1 week" )
		banOption4:SetIcon( "icon16/user_delete.png" )
		banOption4.DoClick = function()
			RunConsoleCommand("ulx", "ban", 10080)
		end

		local banOption5 = ulxBanMenu:AddOption( "1 month" )
		banOption5:SetIcon( "icon16/user_delete.png" )
		banOption5.DoClick = function()
			RunConsoleCommand("ulx", "ban", 43829.1)
		end

		local banOption6 = ulxBanMenu:AddOption( "Permanently" )
		banOption6:SetIcon( "icon16/user_delete.png" )
		banOption6.DoClick = function()
			RunConsoleCommand("ulx", "ban", 0)
		end

		ulxMenu:Open()
	end

	dlist:AddItem(pan)

end

local connect_mat = Material( "icon16/server_connect.png" )

local function CreateName( name, id )

	local pan = vgui.Create( "DPanel" )
	--pan:SetText("")
	pan:SetSize( 0, 22 )
	pan.Paint = function( self, w, h )
		if not self.TeamColor then
			self.TeamColor = Color( 77, 77, 77, 250 )
			surface.SetFont( "Deathrun_Smooth" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
		end
		h = h - 2
		draw.RoundedBox( 4, 0, 2, w, h, self.TeamColor )
		draw.AAText( name, "Deathrun_Smooth", 2 + 16 + 4, h/2 - self.maxH/2 + 2, Color(255, 255, 255, 255) )

		surface.SetDrawColor( Color(255, 255, 255, 255) )
		surface.SetMaterial( connect_mat )
		surface.DrawTexturedRect( 2, 4, 16, 16 )

		draw.AAText( id, "Deathrun_Smooth", w - 5, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
	end

	dlist:AddItem(pan)

end

local function CreateTeamThing( name, color )

	local pan = vgui.Create( "DPanel" )
	pan:SetSize( 0, 20 )
	pan.Paint = function( self, w, h )
		if not self.maxH then
			surface.SetFont( "Deathrun_SmoothMed" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
			self:SetSize( 0, h2 + 5 )
			h = h2 + 5
		end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		draw.AAText( name, "Deathrun_SmoothMed", w/2, h/2 - self.maxH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	dlist:AddItem(pan)

end

local function CreateEmpty( h )

	local pan = vgui.Create( "DPanel" )
	pan:SetSize( 0, h )
	pan.Paint = function() end
	dlist:AddItem(pan)

end

local function Refresh()

	if not dlist then return end

	dlist:Clear()
	local pool = {}

	CreateTeamThing( game.GetMap(), Color( 255, 160, 0, 200 ) )
	CreateEmpty( 20 )

	CreateTeamThing( "Deaths", Color( 160, 50, 50, 200 ) )

	for k, v in pairs( team.GetPlayers(TEAM_DEATH) ) do
		if not v:Alive() then pool[#pool+1] = v continue end
		CreatePlayer(v)
	end

	CreateEmpty( 10 )
	CreateTeamThing( "Runners", Color( 50, 50, 160, 200 ) )

	for k, v in pairs( team.GetPlayers(TEAM_RUNNER) ) do
		if not v:Alive() then pool[#pool+1] = v continue end
		CreatePlayer(v)
	end

	for k, v in pairs( team.GetPlayers(TEAM_SPECTATOR) ) do
		pool[#pool+1] = v
	end

	for k, v in pairs( team.GetPlayers(TEAM_GHOST) ) do
		pool[#pool+1] = v
	end

	if #pool > 0 then

		CreateEmpty( 10 )
		CreateTeamThing( "Dead", Color( 160, 160, 160, 233 ) )

		for k, v in pairs( pool ) do
			if not IsValid(v) then continue end
			CreatePlayer(v)
		end

	end

	local connecting = GAMEMODE:GetConnectingPlayers()

	if table.Count( connecting ) > 0 then

		CreateEmpty( 10 )
		CreateTeamThing( "Connecting", Color( 35, 155, 80, 233 ) )

		for k, v in pairs( connecting ) do
			CreateName( v, k )
		end

	end

	if dlist.VBar then
		dlist.VBar:SetUp( dlist.VBar:GetTall(), dlist:GetTall() )
	end

end

local function CreateScoreboard()

	if scoreboard then
		scoreboard:SetVisible(true)
		Refresh()
		return
	end

	scoreboard = vgui.Create( "DFrame" )
	--
	scoreboard:ShowCloseButton(false)
	scoreboard:SetDraggable(false)
	scoreboard:SetTitle("")
	--
	--scoreboard:SetSize( math.max( ScrW() * 0.5, 600 ), ScrH() * 0.7 )
	scoreboard:SetSize( math.max( ScrW() * 0.3, 300 ), ScrH())
	scoreboard:SetPos(0,0 )
	--scoreboard:Center()
	scoreboard.Paint = ScoreboardPaint
	scoreboard:MakePopup()
	scoreboard:ParentToHUD()

	surface.SetFont( "Deathrun_SmoothBig" )
	local _, h = surface.GetTextSize( "|" )

	dlist = vgui.Create( "DPanelList", scoreboard )
	dlist:SetSize( scoreboard:GetWide() - 10, scoreboard:GetTall() - 10 - (h+4) )
	dlist:SetPos( 5, 5 )
	dlist:EnableVerticalScrollbar(true)
	dlist.Padding = 2

	Refresh()

	/*
	local hn = vgui.Create( "DLabel", scoreboard )
	hn:SetFont( "Deathrun_SmoothBig" )
	hn:SetTextColor( Color( 255, 255, 255, 255 ) )
	hn:SetText( GetHostName() )
	hn:SizeToContents()
	hn:SetPos( 5, scoreboard:GetTall() - 2 - hn:GetTall() )
	*/

end

function GM:ScoreboardShow()

	CreateScoreboard()

end

function GM:ScoreboardHide()

	if not scoreboard then return end
	scoreboard:SetVisible(false)

end
