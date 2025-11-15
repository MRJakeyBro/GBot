AddCSLuaFile()

npcteams = {
	player = {"GBOT_REBEL", "GBOT_HUMAN", "GBOT_PLAYER"},
	npc_alyx = {"GBOT_REBEL", "GBOT_HUMAN"},
	npc_barney = {"GBOT_REBEL", "GBOT_HUMAN"},
	npc_breen = {"GBOT_COMBINE", "GBOT_HUMAN"},
	npc_citizen = {"GBOT_NEUTRAL", "GBOT_HUMAN"},
	npc_dog = {"GBOT_REBEL", "GBOT_ROBOT"},
	npc_eli = {"GBOT_REBEL", "GBOT_HUMAN"},
	npc_fisherman = {"GBOT_NEUTRAL", "GBOT_HUMAN"},
	npc_gman = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_kleiner = {"GBOT_REBEL", "GBOT_HUMAN"},
	npc_magnusson = {"GBOT_REBEL", "GBOT_HUMAN"},
	npc_mossman = {"GBOT_REBEL", "GBOT_HUMAN"},
	npc_odessa = {"GBOT_REBEL", "GBOT_HUMAN"},
	npc_rollermine_hacked = {"GBOT_REBEL", "GBOT_ROBOT"},
	npc_turret_floor_resistance = {"GBOT_REBEL", "GBOT_ROBOT"},
	npc_vortigaunt = {"GBOT_REBEL", "GBOT_ALIEN"},

	npc_citizen_rebel_enemy = {"GBOT_COMBINE", "GBOT_HUMAN"},
	npc_clawscanner = {"GBOT_COMBINE", "GBOT_ROBOT"},
	npc_combine_camera = {"GBOT_COMBINE", "GBOT_ROBOT"},
	npc_combine_s = {"GBOT_COMBINE", "GBOT_HUMAN"},
	npc_combinedropship = {"GBOT_COMBINE", "GBOT_ALIEN"},
	npc_combinegunship = {"GBOT_COMBINE", "GBOT_ALIEN"},
	npc_cscanner = {"GBOT_COMBINE", "GBOT_ROBOT"},
	npc_helicopter = {"GBOT_COMBINE", "GBOT_ROBOT", "GBOT_HUMAN"},
	npc_hunter = {"GBOT_COMBINE", "GBOT_ALIEN"},
	npc_manhack = {"GBOT_COMBINE", "GBOT_ROBOT"},
	npc_metropolice = {"GBOT_COMBINE", "GBOT_HUMAN"},
	npc_rollermine = {"GBOT_COMBINE", "GBOT_ROBOT"},
	npc_rollermine_friendly = {"GBOT_COMBINE", "GBOT_ROBOT"},
	npc_stalker = {"GBOT_COMBINE", "GBOT_HUMAN"},
	npc_strider = {"GBOT_COMBINE", "GBOT_ALIEN"},
	npc_turret_ceiling = {"GBOT_COMBINE", "GBOT_ROBOT"},
	npc_turret_floor = {"GBOT_COMBINE", "GBOT_ROBOT"},

	npc_antlion = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_antlion_grub = {"GBOT_NEUTRAL", "GBOT_ALIEN"},
	npc_antlion_worker = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_antlionguard = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_antlionguardian = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_barnacle = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_fastzombie = {"GBOT_EVIL", "GBOT_ZOMBIE"},
	npc_fastzombie_torso = {"GBOT_EVIL", "GBOT_ZOMBIE"},
	npc_headcrab = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_headcrab_black = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_headcrab_fast = {"GBOT_EVIL", "GBOT_ALIEN"},
	npc_poisonzombie = {"GBOT_EVIL", "GBOT_ZOMBIE"},
	npc_zombie = {"GBOT_EVIL", "GBOT_ZOMBIE"},
	npc_zombie_torso = {"GBOT_EVIL", "GBOT_ZOMBIE"},
	npc_zombine = {"GBOT_EVIL", "GBOT_COMBINE", "GBOT_ZOMBIE"},

	npc_crow = {"GBOT_ANIMAL"},
	npc_monk = {"GBOT_ANIMAL"},
	npc_pigeon = {"GBOT_ANIMAL"},
	npc_seagull = {"GBOT_ANIMAL"}
}

if SERVER then
	hook.Add( "OnEntityCreated", "gbot_bin_relation", function( ent )
		if npcteams[ent:GetClass()] and ent:IsNPC() then
			local hateTeams = {"GBOT_EVIL", "GBOT_ZOMBIE"}

			for _, team in ipairs(npcteams[ent:GetClass()]) do
				if team == "GBOT_COMBINE" then
					table.ForceInsert(hateTeams, "GBOT_REBEL")
				end
				if team == "GBOT_REBEL" then
					table.ForceInsert(hateTeams, "GBOT_COMBINE")
				end
			end

			for _, npc in ipairs(ents.GetAll()) do
				if npc.GBot then
					local hated = false
					for _, team in ipairs(npc.Teams) do
						for _, team2 in ipairs(hateTeams) do
							if team == team2 then hated = true end
						end
					end

					if hated then
						ent:AddEntityRelationship(npc, D_HT, 99)
					end
				end
			end
		end
	end)
end

if CLIENT and WIP then
	hook.Add( "PopulateContent", "PopulateGBOTSpawnmenu", function( pnlContent, tree, node )
		print("populating")

		local ViewPanel = vgui.Create( "ContentContainer", pnlContent )
		ViewPanel:SetVisible( false )
		ViewPanel.IconList:SetReadOnly( true )

		ExampleNode = node:AddNode( "Example", "icon16/folder_database.png" )
		ExampleNode.pnlContent = pnlContent
		ExampleNode.ViewPanel = ViewPanel

		local models = ExampleNode:AddNode( "Models", "icon16/exclamation.png" )
		models.DoClick = function()
			ViewPanel:Clear( true )

			local cp = spawnmenu.GetContentType( "model" )
			if cp then
				for k, v in ipairs( file.Find( "models/*.mdl", "GAME" ) ) do
					cp( ViewPanel, { model = "models/" .. v } )
				end
			end

			ExampleNode.pnlContent:SwitchPanel( ViewPanel )
		end
	end)

    spawnmenu.AddCreationTab( "GBOT", function()
		local ctrl = vgui.Create("SpawnmenuContentPanel")
		ctrl:EnableSearch("GBOT", "PopulateGBOTSpawnmenu")
		ctrl:CallPopulateHook("PopulateGBOTSpawnmenu")
		return ctrl
	end, "icon16/control_repeat_blue.png", 30 )
end

properties.Add( "gbot_possess", {
	MenuLabel = "Control",
	Order = 999,
	MenuIcon = "icon16/fire.png",

	Filter = function( self, ent, plr )
		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end

		if ent.GBot_Possessing then return false end
		if LocalPlayer().GBot_Possessing then return false end

		return ent.GBot or false
	end,
	Action = function( self, ent )
		LocalPlayer().GBot_Possessing = ent
		ent.GBot_Possessing = LocalPlayer()

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, plr )
		local ent = net.ReadEntity()

		plr.GBot_Possess_pos = plr:GetPos()
		plr.GBot_Possessing = ent

		ent.GBot_Possessing = plr

		plr:Spectate( OBS_MODE_CHASE )
		plr:SpectateEntity( plr.GBot_Possessing.cam )
		plr:SetActiveWeapon(NULL)
	end 
} )

hook.Add( "Think", "gbot_possess_lock", function()
	for _, plr in ipairs(player.GetAll()) do
		if plr.GBot_Possessing and not IsValid(plr.GBot_Possessing) then
			GBOT.EndControl(plr.GBot_Possessing, plr)
		end

		if IsValid(plr.GBot_Possessing) and plr.GBot_Possess_pos then
			plr:SetNoTarget( true )
			plr:SetActiveWeapon(NULL)

			if plr:KeyDown( IN_RELOAD ) then
				GBOT.EndControl(plr.GBot_Possessing, plr)
				continue
			end
		end
	end
end)

if CLIENT then
	net.Receive( "gbot_possess_cancel", function( len, ply )
		local ent = net.ReadEntity()
		local plr = net.ReadEntity()

		plr.GBot_Possessing = nil
		ent.GBot_Possessing = nil
	end)
else
	util.AddNetworkString( "gbot_possess_cancel" )
end

GBOT = {}

GBOT.EndControl = function(ent, plr)
	if CLIENT then return end

	plr:SetPos(plr.GBot_Possess_pos)
	plr:UnSpectate()
	plr:SetNoTarget( false )

	plr:Spawn()

	plr:SetPos(plr.GBot_Possess_pos)

	plr.GBot_Possessing = nil
	ent.GBot_Possessing = nil

	net.Start( "gbot_possess_cancel" )
		net.WriteEntity( ent )
		net.WriteEntity( plr )
	net.Broadcast()
end

GBOT.AddNextbot = function(ent, className, catagory)
	local cat = "GBOT"

	if catagory then
		cat = cat .. " | " .. catagory
	end

	ent.GBot = true
	list.Set( "NPC", className, {
		Name = ent.PrintName,
		Class = className,
		Category = cat,
		Teams = ent.Teams
	})
	MsgC( Color(0, 255, 255), "[GBot] ", Color(255, 255, 255), "Added new GBot: \"" .. ent.PrintName .. "\"\n" )
end

GBOT.DrawPath = function(path)
	for _, point in ipairs(path) do
		debugoverlay.Sphere( point.Position, 8, 0.032, Color( 255, 255, 0 ), true )
		if path[_-1] then
			debugoverlay.Line( point.Position, path[_-1].Position, 0.032, Color( 0, 72, 255 ), true )
		end
	end
end

function lerp(a, b, k)
	return a * (1-k) + b * k
end

GBOT.Pathfind = function(ent, pos, opt)
	local path = Path( opt.PathType or "Chase" )
	path:SetMinLookAheadDistance( opt.LookAhead or 4 )
	path:SetGoalTolerance( opt.GoalTolerance or 32 )
	path:Compute( ent, pos )

	if not path:FirstSegment() then
		local gpath = {{Position = ent:GetPos()}, {Position = pos}}
		GBOT.DrawPath(gpath)
		return gpath
	end

	local gpath = {{Position = ent:GetPos()}}

	lastWPP = gpath[#gpath].Position

	local waypoints = path:GetAllSegments()

	if #waypoints > 1 then
		for _, waypoint in ipairs(waypoints) do
			local cast = util.TraceEntityHull({
				start = lastWPP + Vector(0, 0, ent.loco:GetStepHeight()),
				endpos = waypoint.pos + Vector(0, 0, ent.loco:GetStepHeight()),
				filter = {"worldspawn"},
				whitelist = true,
				mask = MASK_NPCSOLID
			}, ent)

			if not cast.Hit then
				cast = util.TraceLine({
					start = lastWPP + Vector(0, 0, ent.loco:GetStepHeight()),
					endpos = waypoint.pos + Vector(0, 0, ent.loco:GetStepHeight()),
					filter = {"worldspawn"},
					whitelist = true,
					mask = MASK_NPCSOLID
				})

				if cast.Hit then
					debugoverlay.Line( lastWPP + Vector(0, 0, ent.loco:GetStepHeight()), waypoint.pos + Vector(0, 0, ent.loco:GetStepHeight()), 0.032, Color( 255, 0, 0 ), true )
				else
					debugoverlay.Line( lastWPP + Vector(0, 0, ent.loco:GetStepHeight()), waypoint.pos + Vector(0, 0, ent.loco:GetStepHeight()), 0.032, Color( 0, 255, 0 ), true )
				end
			end

			local floor = true

			if waypoint.pos:Distance(pos) < 1024 then
				for i = 12,1,-1 do
					local i2 = i + 0.001

					local nx = lerp(lastWPP.X, waypoint.pos.X, i2/12)
					local ny = lerp(lastWPP.Y, waypoint.pos.Y, i2/12)
					local nz = lerp(lastWPP.Z, waypoint.pos.Z, i2/12)

					if lastWPP.Z == waypoint.pos.Z or nz == 1 then
						nz = lastWPP.Z
					end

					local floorCast = util.TraceLine({
						start = Vector(nx, ny, nz),
						endpos = Vector(nx, ny, nz-128),
						filter = {self},
						mask = MASK_NPCSOLID
					})

					if not floorCast.Hit then
						floor = false
						debugoverlay.Line( Vector(nx, ny, nz), Vector(nx, ny, nz-128), 0.032, Color( 255, 0, 0 ), true )
						break
					else
						debugoverlay.Line( Vector(nx, ny, nz), Vector(nx, ny, nz-128), 0.032, Color( 0, 255, 0 ), true )
					end
				end
			end

			if waypoints[_-1] and (cast.Hit or not floor) then
				lastWPP = waypoints[_-1].pos
				gpath[#gpath + 1] = {Position = lastWPP}
			elseif waypoints[_-1] then
				debugoverlay.Sphere( waypoints[_-1].pos, 8, 0.032, Color( 255, 0, 0 ), true )
			end
		end
	end

	gpath[#gpath + 1] = {Position = waypoints[#waypoints].pos}

	for _, p in ipairs(gpath) do
		if gpath[_-1] then
			if p.Position == gpath[_-1].Position then
				table.remove(gpath, _)
			end
		end
	end

	GBOT.DrawPath(gpath)

	return gpath
end

MsgC( Color(0, 255, 255), "[GBot] ", Color(255, 255, 255), "System initialized!\n" )

if false then
	local tiles = {}
	local finished = false

	for x = 25, 1, -1 do
		tiles[x] = {}
		for y = 25, 1, -1 do
			tiles[x][y] = {
				parent = Vector(0, 0, 0),
				type = 0, -- 0 = empty 1 = wall 2 = start 3 = end
				state = 0, -- 0 = unexplored 1 = edge, 2 = used
				distance = 99999,
				path = false
			}
		end
	end

	tiles[1][1].state = 1
	tiles[1][1].type = 2

	local lastTiles = table.Copy( tiles )

	function spreadTile(pos1, pos2, dst)
		if pos2.X <= 0 or pos2.X > 25 then
			return
		end
		if pos2.Y <= 0 or pos2.Y > 25 then
			return
		end

		if lastTiles[pos2.X][pos2.Y].type == 1 then return end

		if lastTiles[pos2.X][pos2.Y].type == 3 then
			tiles[pos2.X][pos2.Y].parent = Vector(pos1.X, pos1.Y, 0)
			finished = true
			return
		end

		if lastTiles[pos2.X][pos2.Y].state ~= 2 and tiles[pos2.X][pos2.Y].distance > tiles[pos1.X][pos1.Y].distance + dst then
			tiles[pos2.X][pos2.Y].parent = Vector(pos1.X, pos1.Y, 0)
			tiles[pos2.X][pos2.Y].distance = lastTiles[pos1.X][pos1.Y].distance + dst
			tiles[pos2.X][pos2.Y].state = 1
		end
	end

	function setGroup(pos, size)
		for x = size.X, 1, -1 do
			for y = size.Y, 1, -1 do
				local trueX = (pos.X-1) + x
				local trueY = (pos.Y-1) + y

				tiles[trueX][trueY].type = 1
			end
		end
	end

	setGroup(Vector(5, 5), Vector(1, 9))
	setGroup(Vector(5, 11), Vector(8, 1))
	setGroup(Vector(5, 4), Vector(10, 1))
	setGroup(Vector(15, 4), Vector(1, 15))

	function setGoal(pos)
		tiles[pos.X][pos.Y].type = 3
	end

	setGoal(Vector(6, 5))

	local lastPath = Vector(6, 5)

	function tick()
		if engine.TickCount() > 660 then
			if not finished then
				for x = 25, 1, -1 do
					for y = 25, 1, -1 do
						if lastTiles[x][y].state == 1 then
							tiles[x][y].state = 2

							if lastTiles[x][y].distance == 99999 and lastTiles[x][y].type == 2 then
								lastTiles[x][y].distance = 0
								tiles[x][y].distance = 0
							end

							spreadTile(Vector(x, y), Vector(x + 1, y), 10)
							spreadTile(Vector(x, y), Vector(x - 1, y), 10)
							spreadTile(Vector(x, y), Vector(x + 1, y-1), 14)
							spreadTile(Vector(x, y), Vector(x - 1, y-1), 14)
							spreadTile(Vector(x, y), Vector(x + 1, y+1), 14)
							spreadTile(Vector(x, y), Vector(x - 1, y+1), 14)
							spreadTile(Vector(x, y), Vector(x, y + 1), 10)
							spreadTile(Vector(x, y), Vector(x, y - 1), 10)
						end
					end
				end

				lastTiles = table.Copy( tiles )
			else
				tiles[lastPath.X][lastPath.Y].path = true
				local par = tiles[lastPath.X][lastPath.Y].parent

				if par.X > 0 and par.X <= 25 then
					if par.Y > 0 and par.Y <= 25 then
						if par and tiles[par.X][par.Y] then
							tiles[par.X][par.Y].path = true
							lastPath = Vector(par.X, par.Y)
						end
					end
				end
			end
		end

		for x = 25, 1, -1 do
			for y = 25, 1, -1 do
				local color = Color(255, 255, 255)

				if tiles[x][y].type == 3 then
					color = Color(0, 255, 0)
				end

				if tiles[x][y].type == 1 then
					color = Color(127, 127, 127)
				end

				if tiles[x][y].state == 1 then
					color = Color(0, 0, 255)
				end
			
				if tiles[x][y].state == 2 then
					color = Color(255, 0, 0)
				end

				if tiles[x][y].path then
					color = Color(255, 255, 0)
				end

				debugoverlay.Box( Vector(x*32, y*32), Vector(-8, -8, -8), Vector(8, 8, 8), 0.54, color)
				debugoverlay.Text( Vector(x*32, y*32, 32), tiles[x][y].distance, 0.54 )

				local par = tiles[x][y].parent

				if par.X ~= 0 or par.Y ~= 0 then 
					local startPos = Vector(par.X * 32, par.Y * 32, 0)
					local endPos = Vector(x * 32, y * 32, 0)

					debugoverlay.Line(startPos, endPos, 0.54, Color(0, 255, 255), true)

					local dir = (endPos - startPos):GetNormalized()
					local arrowSize = 16

					local right = Vector(-dir.y, dir.x, 0)
					local left = Vector(dir.y, -dir.x, 0)

					local arrowTip = endPos
					local arrowBase = endPos - dir * arrowSize

					debugoverlay.Line(arrowTip, arrowBase + right * arrowSize * 0.5, 0.54, Color(0, 255, 255), true)
					debugoverlay.Line(arrowTip, arrowBase + left * arrowSize * 0.5, 0.54, Color(0, 255, 255), true)
				end
			end
		end
	end

	hook.Add( "Think", "breadth", function()
		if engine.TickCount()%33 == 1 then
			tick()
		end
	end)
end