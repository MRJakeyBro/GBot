AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Teams = {"GBOT_NEUTRAL"} --GBOT_PLAYER, GBOT_NEUTRAL, GBOT_REBEL, GBOT_COMBINE, GBOT_EVIL, GBOT_ROBOT, GBOT_HUMAN, GBOT_ALIEN, GBOT_ZOMBIE, GBOT_ANIMAL

ENT.EyeHeight = 64

function ENT:GetBestTarget( opt )
	local opt = opt or {}

	local targetScore = 99999
	local target = nil

	local potentialTargets = {}

	local ip = cvars.Bool( "ai_ignoreplayers", false )

	for _, class in ipairs(opt.TargetClass or {"player"}) do
		table.Add( potentialTargets, ents.FindByClass( class ) )
	end

	for _, ent in ipairs(ents.GetAll()) do
		if ent:IsNextBot() and ent.Teams then

			local done = false
			for _, team in ipairs(ent.Teams) do
				if done then break end

				for _, team2 in ipairs(opt.TargetTeams or {}) do
					
					if team == team2 then
						table.ForceInsert( potentialTargets, ent )	

						done = true
						break
					end

				end
			end

		end

		if npcteams[ent:GetClass()] then
			local done = false
			for _, team in ipairs(npcteams[ent:GetClass()]) do
				if done then break end

				for _, team2 in ipairs(opt.TargetTeams or {}) do
					
					if team == team2 then
						table.ForceInsert( potentialTargets, ent )	

						done = true
						break
					end

				end
			end
		end
	end

	for _, ent in ipairs(potentialTargets) do
		if ent:IsPlayer() and ip then continue end
		if ent:IsPlayer() and ent:IsFlagSet( FL_NOTARGET ) then continue end

		if (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) and ent:IsValid() then
			if opt.LOS then
				tr = util.TraceLine({
					start = ent:GetPos() + Vector(0, 0, 24),
					endpos = self:GetPos() + Vector(0, 0, 24),
					filter = {"worldspawn"},
					whitelist = true
				})
				if tr.Hit then
					tr2 = util.TraceLine({
						start = self:GetPos() + Vector(0, 0, self.EyeHeight),
						endpos = ent:EyePos(),
						filter = {"worldspawn"},
						whitelist = true
					})
					if tr2.Hit then
						continue
					end
				end
			end

			if ent:Health() <= 0 or not ent:Alive() then
				continue
			end

			local entScore = self:EyePos():Distance(ent:EyePos())
			if opt.Health then
				entScore = entScore + ent:Health()
			end

			if opt.ScoreMod then
				local score, cont = opt.ScoreMod(ent, entScore)

				if cont == false then
					continue
				end

				entScore = score
			end

			if entScore < targetScore then
				targetScore = entScore
				target = ent
			end
		end
	end

	return target
end

function ENT:Step( pos, opt )
	if cvars.Bool( "ai_disabled", false ) then return end

	local opt = opt or {}

	self.loco:SetAcceleration( opt.Acceleration or 800 )
	self.loco:SetDesiredSpeed( opt.Speed or 400 )

	if self.GBot_Possessing then
		local dir = pos-self:GetPos()
		dir = Vector(dir.x, dir.y, 0)

        self.loco:FaceTowards( self:GetPos() + dir * 50 )
		self.loco:Approach( pos, opt.GoalTolerance or 32 )
		return
	end

	local path = GBOT.Pathfind( self, pos, opt )

	if #path > 1 then
		local dir = path[2].Position-self:GetPos()
		dir = Vector(dir.x, dir.y, 0)

        self.loco:FaceTowards( self:GetPos() + dir * 50 )
		self.loco:Approach( path[2].Position, opt.GoalTolerance or 32 )

		if self.loco:GetVelocity():Length() < math.min(128, opt.Speed or 400) then
			self.loco:SetVelocity(dir:GetNormalized()*math.min(128, opt.Speed or 400))
		end
	end

	if self.loco:IsStuck() then
		if path[2] and path[3] then
			local forward = (path[3].Position-path[2].Position):GetNormalized()

			for _, ent in ipairs(ents.FindInSphere( self:GetPos(), 64 )) do
				if (self:GetPos()-ent:GetPos()).Z > 0 then continue end
				self:SetPos(self:GetPos() + (self:GetPos()-ent:GetPos())/4)
			end

			self:SetPos(self:GetPos() + (forward + Vector(0, 0, math.random(1, 50)/50)))
		end

		self:HandleStuck()
	end
end

function ENT:DealDamage( target, dmg, type )
	if not IsValid(target) then return end

    local dmginfo = DamageInfo()
    dmginfo:SetDamage(dmg)
    dmginfo:SetAttacker(self)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamageType(type)

    target:TakeDamageInfo(dmginfo)

	if target:IsNPC() then
		target:AddEntityRelationship( self, D_HT, 999 )
		target:UpdateEnemyMemory(self, self:GetPos())
		target:MarkTookDamageFromEnemy( self )
		target:SetEnemy( self, true )
	end
end

function ENT:Activity( act )
	if self:GetActivity() ~= act then
		self:StartActivity( act )
	end
end

function ENT:Sequence( act, spd )
	if self:GetSequenceName( self:GetSequence() ) ~= act then
		self:SetSequence( act )
		self:ResetSequence( act )
	end

	self:SetPlaybackRate( spd or 1 )
end

function ENT:RunBehaviour()
	if not IsValid(self.cam) then
		self.cam = ents.Create("prop_dynamic")
		self.cam:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self.cam:SetParent( self )
		self.cam:SetPos(self:GetPos()+Vector(0, 0, self.EyeHeight/2 + 32))
		self.cam:Spawn()
		self.cam:SetColor(Color( 0, 0, 0, 0 ))
		self.cam:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	while true do
		if not self.GBot_Possessing then
			if not cvars.Bool( "ai_disabled", false ) then
				if self.Tick then
					self:Tick()
				end
			end
		else
			if not IsValid(self.GBot_Possessing) then
				GBOT.EndControl(self, self.GBot_Possessing)
				continue
			end

			if self.PossessedTick then
				local forward = 0
				local right = 0

				if self.GBot_Possessing:KeyDown( IN_FORWARD ) then
					forward = forward + 1
				end
				if self.GBot_Possessing:KeyDown( IN_BACK ) then
					forward = forward - 1
				end
				if self.GBot_Possessing:KeyDown( IN_MOVELEFT ) then
					right = right - 1
				end
				if self.GBot_Possessing:KeyDown( IN_MOVERIGHT ) then
					right = right + 1
				end

				local cright = self.GBot_Possessing:EyeAngles():Right()*right
				local cforward = self.GBot_Possessing:EyeAngles():Forward()*forward

				local dir = cright + cforward
				dir = Vector(dir.x, dir.y, 0):GetNormalized()

				self:PossessedTick(dir, self.GBot_Possessing)
			end
		end

		coroutine.wait( .01 )
	end
end

function ENT:UpdateTransmitState()
	if self.GBot_Possessing then
		return TRANSMIT_ALWAYS
	end
	
	return TRANSMIT_PVS
end