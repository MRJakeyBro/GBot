if not GBOT then return end
AddCSLuaFile()

ENT.Base		= "base_gbot"
ENT.PrintName	= "Antlion"
ENT.Spawnable	= true

ENT.Teams = {"GBOT_EVIL", "GBOT_ALIEN"}

ENT.EyeHeight = 24

if CLIENT then
	language.Add( "npc_gbot_antlion", "Antlion [GBOT]" )
end

function ENT:Initialize()
	self:SetModel( "models/AntLion.mdl" )
	self:SetSkin(math.random(0, self:SkinCount()-1))

	self:SetHealth( 30 )
	if SERVER then
		self:SetMaxHealth( 30 )
		self:SetBloodColor( BLOOD_COLOR_ANTLION )
	end
end

ENT.soundtick = 100
ENT.stunned = false
ENT.scared = 0

function ENT:SharedMove(jump)
	if self.TargetPos then
		if jump then
			local dir = self.TargetPos - self:GetPos()

			for _, ent in ipairs(ents.FindInSphere( self:GetPos(), 64 )) do
				dir = dir + (self:GetPos()-ent:GetPos()):GetNormalized()/8
			end

			dir = Vector(dir.X, dir.Y, 0):GetNormalized()

			self:SetAngles( dir:Angle() )
			self.loco:JumpAcrossGap( self:GetPos() + dir * 768, dir )
		
			coroutine.wait(0.2)
			while not self:IsOnGround() do
				coroutine.wait(0.01)
			end
		else
			self:Activity( ACT_RUN )

			self:Step( self.TargetPos, {
				Acceleration = 1600,
				Speed = 300,
				Debug = true
			})

			if self.TargetPos:Distance(self:GetPos()) < 64 then
				self.TargetPos = nil
			end
		end
	else
		self:Activity( ACT_IDLE )

		local bait = sound.GetLoudestSoundHint( SOUND_BUGBAIT, self:GetPos() )

		if bait then
			self.TargetPos = bait.origin
			self.scared = self.scared - 3
		end
	end
end

function ENT:Attack(target)
	self:Activity( ACT_MELEE_ATTACK1 )
	self:EmitSound( "npc/antlion/attack_single" .. math.random(1, 3) .. ".wav", 75 )

	for i = 1, 50 do
		coroutine.wait(0.01)
		if self.stunned then return end
	end

	if IsValid(target) then
		if target:GetPos():Distance(self:GetPos()) < 96 then
			self:DealDamage( target, 5, DMG_SLASH )
		end
	end

	for i = 1, 50 do
		coroutine.wait(0.01)
		if self.stunned then return end
	end
end

function ENT:StunDetectHandle()
	if self.stunned then
		self:Activity( ACT_IDLE )

		self:PlaySequenceAndWait( "Flip1", 1 )
		self:ResetSequenceInfo()

		self:Activity( ACT_IDLE )
		self.stunned = false
	end
end

function ENT:Tick()
	self:StunDetectHandle()

	self.scared = self.scared - 1
	self.soundtick = self.soundtick - 1

	local target = self:GetBestTarget( {TargetClass = {}, TargetTeams = {"GBOT_HUMAN", "GBOT_ZOMBIE"}, Health = true, LOS = true,  ScoreMod = function(ent, score)
		if ent:IsPlayer() and ent:HasWeapon( "weapon_bugbait" ) then
			return score, false
		end

		return score
	end})

	if self.soundtick <= 0 then
		self.soundtick = math.random(100, 300)
		self:EmitSound( "npc/antlion/idle" .. math.random(1, 5) .. ".wav", 75 )
	end

	if IsValid(target) and self.scared <= 0 then
		self.TargetPos = target:GetPos()
		if target:GetPos():Distance(self:GetPos()) < 96 then
			self:Attack(target)
		end
	end

	local thump = sound.GetLoudestSoundHint( SOUND_THUMPER, self:GetPos() )
	if thump then
		local dir = self:GetPos()-thump.origin
		dir:Normalize()
		
		self.TargetPos = thump.origin + dir * 640

		self.scared = 100
	end

	local jump = false

	if self.TargetPos then
		jump = (self:GetPos():Distance(self.TargetPos) > 1000 and (self.TargetPos-self:GetPos()).Z < 128) or ((self.TargetPos-self:GetPos()).Z > 128 and (self.TargetPos-self:GetPos()).Z < 256 and self:GetPos():Distance(self.TargetPos) > 128 and self:GetPos():Distance(self.TargetPos) < 512)
	end

	self:SharedMove(jump and math.random(1, 100) == 1)
end

function ENT:PossessedTick( moveDir, plr )
	self:StunDetectHandle()

	if plr:KeyDown( IN_ATTACK ) then
		self:Attack(self:GetBestTarget( {TargetClass = {}, TargetTeams = {"GBOT_HUMAN", "GBOT_ZOMBIE"}, Health = true, LOS = true} ))
	end

	if moveDir:Length() <= 0.2 then
		self.TargetPos = nil
	else
		self.TargetPos = self:GetPos() + moveDir*64
	end

	self:SharedMove(plr:KeyDown( IN_JUMP ))
end

function ENT:OnTakeDamage()
	self:EmitSound( "npc/antlion/pain" .. math.random(1, 2) .. ".wav", 75 )
end

function ENT:GravGunPunt( plr )
	if self.stunned then return false end
	self.stunned = true
	return true
end

GBOT.AddNextbot(ENT, "npc_gbot_antlion")