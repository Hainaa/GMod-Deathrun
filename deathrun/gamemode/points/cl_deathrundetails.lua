function CreateMapDetailsPanel(maps, players)
	local MapDetailsFrame = vgui.Create("DFrame")
	MapDetailsFrame:SetSize(math.max(700, ScrW()/3), math.max(600, ScrH()/4))
	MapDetailsFrame:Center()
	MapDetailsFrame:SetTitle("Deathrun Map and Player Stats")
	MapDetailsFrame:SetDraggable(false)

	surface.SetFont("DermaLarge")
	local MDF_sizeX, MDF_sizeY = MapDetailsFrame:GetSize()
	local MT_sizeX, MT_sizeY = surface.GetTextSize(game.GetMap())

	local MapTitle = vgui.Create( "DLabel", MapDetailsFrame )
	MapTitle:SetFont("DermaLarge")
	MapTitle:SetPos(MDF_sizeX/2 - MT_sizeX / 2, MDF_sizeY * 0.5/10)
	MapTitle:SetSize(MT_sizeX, MT_sizeY)
	MapTitle:SetText(game.GetMap())

	CreateStatTabs(MapDetailsFrame, maps, players)

	surface.SetFont("DermaDefault")
	local HS_sizeX, HS_sizeY = surface.GetTextSize("Hide your stats?")

	local HideStatsCheckBox = vgui.Create("DCheckBox", MapDetailsFrame)

	for k1,v1 in pairs(players) do
		if v1["steamid"] == LocalPlayer():SteamID() then
			HideStatsCheckBox:SetValue(tonumber(v1["score_hidden"]))
			break
		end
	end

	function HideStatsCheckBox:DoClick()
		net.Start("ToggleHideStats")
			net.WriteBool(HideStatsCheckBox:GetChecked())
		net.SendToServer()

		HideStatsCheckBox:Toggle()
	end
	HideStatsCheckBox:SetPos(MDF_sizeX/2 - HS_sizeX / 1.25,  MDF_sizeY * 0.96)

	local HideStatsLabel = vgui.Create( "DLabel", MapDetailsFrame )
	HideStatsLabel:SetFont("DermaDefault")
	HideStatsLabel:SetSize(HS_sizeX, HS_sizeY)
	HideStatsLabel:SetPos(MDF_sizeX/2 - HS_sizeX / 2, MDF_sizeY * 0.96)
	HideStatsLabel:SetText("Hide your stats?")

	MapDetailsFrame:MakePopup()
end

function CreateStatTabs(panel, maps, players)
	local panelx, panely = panel:GetSize()

	local StatSheet = vgui.Create( "DPropertySheet", panel )
	StatSheet:SetSize(panelx * 0.95, panely * 0.85)
	StatSheet:SetPos(panelx * 0.025, panely * 0.1)

	local sheetx, sheety = StatSheet:GetSize()

	local MapStatTab = vgui.Create( "DPanel", StatSheet )
	local MapStatList = vgui.Create( "DListView", MapStatTab )
	MapStatList:SetSortable(false)
	MapStatList:SetSelectable(false)
	MapStatList:AddColumn("Stat")
	MapStatList:AddColumn("Value")
	MapStatList:SetSize(sheetx, sheety)
	function MapStatList.Paint(self, w, h)
		for k,v in pairs(self.Columns) do
			function v:Paint(self2, w, h)
				draw.RoundedBox(0, 0, 0, panelx, panely, Color(160, 160, 160))
			end
		end
	end

	MapStatList:AddLine("Last Beaten By", maps[1]["last_beaten_by"])
	MapStatList:AddLine("Rounds Played", maps[1]["times_played"])
	MapStatList:AddLine("Rounds Won", maps[1]["times_won"])
	MapStatList:AddLine("Rounds Lost", maps[1]["times_lost"])
	MapStatList:AddLine("Times End Reached", maps[1]["times_end_reached"])
	MapStatList:AddLine("Reward Multiplier", maps[1]["reward_mult"])

	StatSheet:AddSheet("Map Stats", MapStatTab)

	local PlayerStatTab = vgui.Create( "DPanel", StatSheet )
	local PlayerStatList = vgui.Create( "DListView", PlayerStatTab )
	PlayerStatList:SetSortable(false)
	PlayerStatList:SetSelectable(false)
	PlayerStatList:AddColumn("Name")
	PlayerStatList:AddColumn("Rounds Played")
	PlayerStatList:AddColumn("Ends reached")
	PlayerStatList:AddColumn("Runner Win/Loss")
	PlayerStatList:AddColumn("Death Win/Loss")
	PlayerStatList:SetSize(sheetx, sheety)
	function PlayerStatList.Paint(self, w, h)
		for k,v in pairs(self.Columns) do
			v:SetContentAlignment(5)
			function v:Paint(self2, w, h)
				draw.RoundedBox(0, 0, 0, panelx, panely, Color(160, 160, 160))
			end
		end
	end

	for k, v in pairs(players) do
		if v["score_hidden"] ~= '1' then
			PlayerStatList:AddLine(v["ply_name"], v["rounds_played"], v["times_end_reached"], 
				v["times_won_runner"] .. "/" .. v["times_lost_runner"], v["times_won_death"] .. "/" .. v["times_lost_death"])
		end
	end

	StatSheet:AddSheet("Player Stats", PlayerStatTab)

	--[[
		ply_name varchar(255),
				rounds_played int,
				steamid varchar(255),
				times_won_runner int,
				times_lost_runner int,
				times_won_death int,
				times_lost_death int,
				times_end_reached int
	]]
end

net.Receive("SendTables", function()
	local maps = net.ReadTable()
	local players = net.ReadTable()

	CreateMapDetailsPanel(maps, players)
end)