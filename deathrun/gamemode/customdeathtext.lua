if SERVER then
	util.AddNetworkString( "DeathNotice" )

	function GM:PlayerDeath( victim, inflictor, attacker)

		local victimName, inflictorName, attackerName, noticeTable
		local killMessage

		if attacker:IsPlayer() and victim ~= attacker then
			attackerName = attacker:Name()
			inflictorName = attacker:GetActiveWeapon():GetClass()
			killMessage = math.random(1, countDeathTexts(false))
		else
			attackerName = ""
			inflictorName = inflictor:GetClass()
			killMessage = math.random(1, countDeathTexts(true))
		end

		victimName = victim:Name()

		print(victimName)

		if inflictorName == "player" then
			inflictorName = false
		end

		noticeTable = {
			["victim"] = victimName,
			["inflictor"] = inflictorName,
			["attacker"] = attackerName,
			["killMessage"] = killMessage
		}

		net.Start("DeathNotice")
			net.WriteTable(noticeTable)
		net.Broadcast()

	end
end

if CLIENT then
	surface.CreateFont( "Deathrun_Smooth", { font = "Trebuchet18", size = 14, weight = 700, antialias = true } )

	net.Receive( "DeathNotice", function(len) printPlayerDeath(net.ReadTable()) end)
end

soloDeathTexts = {
	"%s has been scrambled",
	"%s tried to bhop but slipped",
	"%s becomes bored with life",
	"%s was probably killed by a monster",
	"%s died",
	"%s saw the light",
	"%s wanted to try and see what it was like to commit suicide",
	"%s had aneurysm",
	"%s tried to trick Death but was too slow",
	"%s sacrifices themselves so the leechers can get past",
	"%s was probably leeching anyway",
	"%s went too fast",
	"%s was bit by a cat"
}

multiDeathTexts = {
	"%s died. I blame %s",
	"%s gets no say in it, no say in it at all! sings %s",
	"%s is all partied out by %s",
	"%s is put to sleep by %s",
	"%s doesn't know how to use a weapon, so %s showed them how",
	"%s was killed by %s",
	"%s got too close to %s",
	"%s tried to invade %s's personal space",
	"%s was tripped by %s",
	"%s was slapped by %s really hard",
	"%s lost to %s in a game of rock, paper, scissors",
	"%s was knocked to the ground by %s"
}

function countDeathTexts( isSolo )
	local count = 0
	if isSolo then
		for _,_ in pairs(soloDeathTexts) do
			count = count + 1
		end
	else
		for _,_ in pairs(multiDeathTexts) do
			count = count + 1
		end
	end
	return count
end

--- Custom death messages ---

if CLIENT then
	local deathMessages = {}

	function printPlayerDeath(noticeTable)

		victim = noticeTable["victim"]

		attacker = noticeTable["attacker"]
		inflictor = noticeTable["inflictor"]
		random = noticeTable["killMessage"]

		--[[
		for k, v in pairs(noticeTable) do
			print( k .. " " .. v)
		end
		]]

		if victim ~= attacker and attacker ~= "" then
			--random = math.random(1, countDeathTexts(false))
			print( string.format( multiDeathTexts[random] , victim, attacker ) )
		else
			--random = math.random(1, countDeathTexts(true))
			print( string.format( soloDeathTexts[random] , victim ) )
		end
	end
end
