DRA_DB = DRA_DB or {}

DRA_DB.WonRunner = 1
DRA_DB.WonDeath = 2
DRA_DB.LostRunner = 3
DRA_DB.LostDeath = 4
DRA_DB.ReachedEnd = 5
DRA_DB.RoundsPlayed = 6
DRA_DB.HideScore = 7

DRSTATS = DRSTATS or {}

DRSTATS.Commands = {
	"/stats",
	"!stats",
	"stats"
}

util.AddNetworkString( "SendTables" )
util.AddNetworkString( "ToggleHideStats" )

function DRA_checktables()
	if not sql.TableExists("dra_maps") then
		sql.Query(
			[[CREATE TABLE dra_maps
			(
				map_name varchar(255),
				last_beaten_by varchar(255),
				last_beaten_by_id varchar(255),
				times_played int,
				times_won int,
				times_lost int,
				times_end_reached int,
				reward_mult single
			);]]
		)
	end

	if not sql.TableExists("dra_players") then
		sql.Query(
			[[CREATE TABLE dra_players
			(
				ply_name varchar(255),
				rounds_played int,
				steamid varchar(255),
				times_won_runner int,
				times_lost_runner int,
				times_won_death int,
				times_lost_death int,
				times_end_reached int,
				score_hidden boolean
			);]]
		)
	end

	if not sql.TableExists("dra_ply_mapsfinished") then
		sql.Query(
			[[CREATE TABLE dra_ply_mapsfinished
			(
				steamid varchar(255),
				map_name varchar(255)
			);]]
		)
	end
end

function DRA_checkmap()
	map_exist = sql.Query("SELECT map_name from dra_maps where map_name = '" .. game.GetMap() .. "'")

	if map_exist == nil then
		sql.Query("INSERT INTO dra_maps VALUES ('" .. game.GetMap() .. "', 'nobody', 'nobody', 0, 0, 0, 0, 1)")
	end
end

function DRA_start()
	DRA_checktables()
	DRA_checkmap()
end

DRA_start()

DRA_DB.DRA_set_last_beat = function(ply)
	sql.Query("UPDATE dra_maps SET last_beaten_by='" .. ply:Name() .. "',last_beaten_by_id='" .. ply:SteamID() .. "' WHERE map_name = '" .. game.GetMap() .. "'")
end

DRA_DB.DRA_map_add_winlost = function(iswin)
	if iswin then
		sql.Query("UPDATE dra_maps SET times_won=times_won+1 WHERE map_name = '" .. game.GetMap() .. "'")
	else
		sql.Query("UPDATE dra_maps SET times_lost=times_lost+1 WHERE map_name = '" .. game.GetMap() .. "'")
	end
end

DRA_DB.DRA_map_add_endreach = function()
	sql.Query("UPDATE dra_maps SET times_end_reached=times_end_reached+1 WHERE map_name = '" .. game.GetMap() .. "'")
end

DRA_DB.DRA_map_add_timesplayed = function()
	sql.Query("UPDATE dra_maps SET times_played=times_played+1 WHERE map_name = '" .. game.GetMap() .. "'")
end

DRA_DB.DRA_map_set_mult_modify = function(value)
	mult = tonumber(value)

	if mult < 0.1 then
		mult = 0.1
	elseif mult > 5 then
		mult = 5
	end

	sql.Query("UPDATE dra_maps SET reward_mult=" .. mult .. " WHERE map_name = '" .. game.GetMap() .. "'")
end

DRA_DB.DRA_map_get_mult_modify = function()
	return tonumber(sql.QueryValue("SELECT reward_mult FROM dra_maps WHERE map_name = '" .. game.GetMap() .. "'"))
end

DRA_DB.DRA_map_set_win = function(value)
	mapmult = sql.Query("SELECT times_won FROM dra_maps WHERE map_name = '" .. game.GetMap() .. "'")

	sql.Query("UPDATE dra_maps SET times_won=" .. value .. " WHERE map_name = '" .. game.GetMap() .. "'")
end

DRA_DB.DRA_ply_mod_stats = function(ply, type, val)
	ply_exist = sql.Query("SELECT steamid from dra_players WHERE steamid = '" .. ply:SteamID() .. "'")

	if ply_exist == nil then
		sql.Query("INSERT INTO dra_players VALUES ('" .. ply:Name() .. "', 0, '" .. ply:SteamID() .. "', 0, 0, 0, 0, 0, 0)")
	end

	sql.Query("UPDATE dra_players SET ply_name='" .. ply:Name() .. "' WHERE steamid = '" .. ply:SteamID() .. "'")

	if type == DRA_DB.ReachedEnd then
		sql.Query("UPDATE dra_players SET times_end_reached=times_end_reached+1 WHERE steamid = '" .. ply:SteamID() .. "'")
	end

	if type == DRA_DB.WonRunner then
		sql.Query("UPDATE dra_players SET times_won_runner=times_won_runner+1 WHERE steamid = '" .. ply:SteamID() .. "'")
	end

	if type == DRA_DB.LostRunner then
		sql.Query("UPDATE dra_players SET times_lost_runner=times_lost_runner+1 WHERE steamid = '" .. ply:SteamID() .. "'")
	end

	if type == DRA_DB.WonDeath then
		sql.Query("UPDATE dra_players SET times_won_death=times_won_death+1 WHERE steamid = '" .. ply:SteamID() .. "'")
	end

	if type == DRA_DB.LostDeath then
		sql.Query("UPDATE dra_players SET times_lost_death=times_lost_death+1 WHERE steamid = '" .. ply:SteamID() .. "'")
	end

	if type == DRA_DB.RoundsPlayed then
		sql.Query("UPDATE dra_players SET rounds_played=rounds_played+1 WHERE steamid = '" .. ply:SteamID() .. "'")
	end

	if type == DRA_DB.HideScore then
		sql.Query("UPDATE dra_players SET score_hidden=" .. val .. " WHERE steamid = '" .. ply:SteamID() .. "'")
	end
end

DRA_DB.DRA_ply_mapend = function(ply)
	plymap_exist = sql.Query("SELECT steamid, map_name FROM dra_ply_mapsfinished WHERE steamid = '" .. ply:SteamID() .. "' AND map_name = '" .. game.GetMap() .. "'")

	if plymap_exist == nil then
		print("Hello")
		sql.Query("INSERT INTO dra_ply_mapsfinished VALUES ( '" .. ply:SteamID() .. "', '" .. game.GetMap() .. "' )")
	end
end

DRA_DB.DRA_send_tables_currentmap = function(ply)
	local maps = sql.Query("SELECT * FROM dra_maps WHERE map_name = '" .. game.GetMap() .. "'")
	local players = sql.Query("SELECT * FROM dra_players")

	net.Start("SendTables")
		net.WriteTable(maps)
		if players == nil then
			players = {}
		end
		net.WriteTable(players)
	net.Send(ply)
end

hook.Add("PlayerSay", "Send Stats to player", function(ply, text, tc)
	if table.HasValue(DRSTATS.Commands, string.lower(text)) then
		DRA_DB.DRA_send_tables_currentmap(ply)
	end
end)

net.Receive("ToggleHideStats", function(len, ply)
	local hiddentoggle = tonumber(sql.QueryValue("SELECT score_hidden FROM dra_players WHERE steamid='" .. ply:SteamID() .. "'"))

	if hiddentoggle == 1 then hiddentoggle = 0 else hiddentoggle = 1 end

	DRA_DB.DRA_ply_mod_stats(ply, DRA_DB.HideScore, hiddentoggle)
end)
