if not GBOT then return end
AddCSLuaFile()

ENT.Base		= "base_gbot"
ENT.PrintName	= "Combine Killer"
ENT.Spawnable	= true

ENT.Teams = {"GBOT_REBEL", "GBOT_HUMAN"}

ENT.EyeHeight = 64

if CLIENT then
	language.Add( "npc_gbot_combine_killer", "Combine Killer [GBOT]" )
end

function ENT:Initialize()
	self:SetModel( "models/Humans/Group03/male_07.mdl" )

	self:SetHealth( 300 )
	if SERVER then
		self:SetMaxHealth( 300 )
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

function ENT:Tick()
	local target = self:GetBestTarget( {TargetClass = {}, TargetTeams = {"GBOT_COMBINE"}, Health = true, LOS = true} )

	if IsValid(target) then
		self.TargetPos = target:GetPos()

		if target:GetPos():Distance(self:GetPos()) < 64 then
			target:TakeDamage( 1, self, self )
		end
	end

	self:SharedMove()
end

function ENT:PossessedTick( moveDir, plr )
	if moveDir:Length() <= 0.2 then
		self.TargetPos = nil
	else
		self.TargetPos = self:GetPos() + moveDir*64
	end

	self:SharedMove()
end

GBOT.AddNextbot(ENT, "npc_gbot_combine_killer")