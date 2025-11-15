if not GBOT then return end
AddCSLuaFile()

ENT.Base		= "base_gbot"
ENT.PrintName	= "Metrocop"
ENT.Spawnable	= true

ENT.Teams = {"GBOT_EVIL", "GBOT_COMBINE"}

ENT.EyeHeight = 24

if CLIENT then
	language.Add( "npc_gbot_metro", "Metrocop [GBOT]" )
end

function ENT:Initialize()
	self:SetModel( "models/Police.mdl" )

	self:SetHealth( 40 )
	if SERVER then
		self:SetMaxHealth( 40 )
	end
end

function ENT:SharedMove()
	if self.TargetPos then
		self:Activity( ACT_RUN )

		self:Step( self.TargetPos, {
			Acceleration = 1600,
			Speed = 300
		})

		if self.TargetPos:Distance(self:GetPos()) < 64 then
			self.TargetPos = nil
		end
	else
		self:Activity( ACT_IDLE )
	end
end

function ENT:Attack(target)
	self:Activity( ACT_MELEE_ATTACK1 )
	self:EmitSound( "npc/antlion/attack_single" .. math.random(1, 3) .. ".wav", 75 )

	for i = 1, 50 do
		coroutine.wait(0.01)
	end

	if IsValid(target) then
		if target:GetPos():Distance(self:GetPos()) < 96 then
			self:DealDamage( target, 5, DMG_SLASH )
		end
	end

	for i = 1, 50 do
		coroutine.wait(0.01)
	end
end

function ENT:Tick()
	local target = self:GetBestTarget( {TargetClass = {}, TargetTeams = {"GBOT_REBEL"}, Health = true, LOS = true})

	if IsValid(target) then
		self.TargetPos = target:GetPos()

		if target:GetPos():Distance(self:GetPos()) < 96 then
			self:Attack(target)
		end
	end

	self:SharedMove()
end

function ENT:PossessedTick( moveDir, plr )
	if plr:KeyDown( IN_ATTACK ) then
		self:Attack(self:GetBestTarget( {TargetClass = {}, TargetTeams = {"GBOT_REBEL"}, Health = true, LOS = true} ))
	end

	if moveDir:Length() <= 0.2 then
		self.TargetPos = nil
	else
		self.TargetPos = self:GetPos() + moveDir*64
	end

	self:SharedMove()
end

GBOT.AddNextbot(ENT, "npc_gbot_metro")