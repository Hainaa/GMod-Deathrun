DRPOINTS = DRPOINTS or {}

DRPOINTS.PositionPoints = {
	[1] = 200, --[Position] = Points, add as many here as you like
	[2] = 100,
	[3] = 50 
}

DRPOINTS.Default = 10

DRPOINTS.DeathKill = 10

DRPOINTS.RunnerKill = 20

DRPOINTS.MinPlayers = 5

DRPOINTS.WinningTeam = 5

DRPOINTS.WinDecayRate = 2
DRPOINTS.LoseGrowthRate = 0.1

DRPOINTS.PointMultMax = 5
DRPOINTS.PointMultMin = 0.1

--[[
def equation(rate, n, run):
    if n > 4.95:
        print("Run: " + str(run))
        print("N: %.2f" % 5)
        return True
    run += 1
    print("Run: " + str(run))
    print("N: %.2f" % n)
    equation(rate, n + (rate - rate * (n - 0.5)/5), run)

equation(0.1, 0.1, 0)
]]