function GM:RenderScreenspaceEffects()
	
	self:DoTrace()
 
end

function GM:DoTrace()

	local lp = LocalPlayer()
	
	if IsValid( lp ) then
	
		if lp:GetObserverMode() > OBS_MODE_NONE and lp:GetObserverMode() != OBS_MODE_ROAMING then
		
			self.TargetEnt = lp:GetObserverTarget()
			self.ViewDist = 0
			
			if IsValid( self.TargetEnt ) then
			
				self.HitPos = self.TargetEnt:GetPos()
				
			end
			
			return
			
		end
	
		local dir = ( lp:EyeAngles() + lp:GetPunchAngle() ):Forward()
		
		local trace = {}
		trace.start = lp:GetShootPos()
		trace.endpos = trace.start + dir * 9000
		trace.filter = { lp, lp:GetActiveWeapon() } 
		trace.mask = MASK_SHOT
		
		local tr = util.TraceLine( trace )
			
		self.ViewDist = tr.HitPos:Distance( EyePos() )
		self.HitPos = tr.HitPos
		self.TargetEnt = tr.Entity
		
	end

end
 
function GM:PreDrawHalos()

	if not IsValid( self.TargetEnt ) then return end

	local ply = LocalPlayer()
	if not ply:Alive() or ply:GetObserverMode() == OBS_MODE_ROAMING then return end

	local dist = math.Clamp( self.ViewDist or 0, 0, 800 )
	local scale = 1 - ( dist / 800 ) 

	if self.TargetEnt:IsPlayer() then
		if self.TargetEnt:Team() == TEAM_RUNNER then
			halo.Add( { self.TargetEnt, self.TargetEnt:GetActiveWeapon() }, Color( 0, 200, 255 ), 2, 2, 1, 1, false )
		elseif self.TargetEnt:Team() == TEAM_DEATH then
			halo.Add( { self.TargetEnt, self.TargetEnt:GetActiveWeapon() }, Color( 255, 0, 0 ), 2, 2, 1, 1, false )
		end
	end

end