LEVEL1_ABILITIES = 
{
	[1] = "build_normal_farm",
	[2] = "build_tiny_farm",
	[3] = "build_hard_farm",
	[4] = "build_upgraded_farm",
	[5] = "build_stack_farm",
	[6] = "level2_abilities",
}

LEVEL2_ABILITIES = 
{
	--[1] = "build_aura_farm",
	[1] = "build_sentry_farm",
	[2] = "build_strong_farm",
	[3] = "build_wide_farm",
	[4] = "build_savings_farm",
	[5] = "build_invisible_farm",
	[6] = "level1_abilities",
}

--[[
	Author: Noya
	Date: 19.02.2015.
	Replaces the building to the upgraded unit name
]]
function UpgradeBuilding( event )
	local caster = event.caster
	local new_unit = event.UnitName
	local position = caster:GetAbsOrigin()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local playerID = hero:GetPlayerID()
	local player = PlayerResource:GetPlayer(playerID)
	local currentHealthPercentage = caster:GetHealth()/caster:GetMaxHealth()

	-- Keep the gridnav blockers and hull radius
	local blockers = caster.blockers
	local builder = caster.builder
	local hull_radius = caster:GetHullRadius()
	local flag = caster.flag

	local contructionSize = caster.construction_size

	-- Remove the old building from the structures list
	if IsValidEntity(caster) then	
		-- Remove old building entity
		caster:RemoveSelf()

    end

	local bID = GetIndex(caster.builder.farms, caster)

    -- New building
	local building = BuildingHelper:PlaceBuilding(player, new_unit, position, contructionSize, 2, nil) 
	building.blockers = blockers
	building.builder = builder
	building.construction_size = contructionSize
	building:SetHullRadius(hull_radius)
	building:SetModelScale(event.MaxScale)
	InitAbilities(building)

	GiveUnitDataDrivenModifier(building, building, "modifier_farm_death_datadriven", -1)
	GiveUnitDataDrivenModifier(building, building, "modifier_farm_no_turn_datadriven", -1)
	GiveUnitDataDrivenModifier(building, building, "modifier_farm_built_datadriven", -1)
	GiveUnitDataDrivenModifier(building, building, "modifier_farm_no_health_bar_datadriven", -1)
	
	if bID ~= -1 then
		building.builder.farms[bID] = building
	end
	--table.insert(hero.farms, 1, building)

	local newRelativeHP = math.ceil(building:GetMaxHealth() * currentHealthPercentage)
	if newRelativeHP == 0 then newRelativeHP = 1 end --just incase rounding goes wrong
	building:SetHealth(newRelativeHP)
	building:SetMana(0)

	print("Building upgrade complete.")
end
-- End Building Helper Functions

-- Disable sheep auto attack
function sheep_attack_check( keys )
	local target = keys.target
	local caster = keys.caster
	if target:GetUnitName() == "npc_dota_hero_lycan" or target:GetUnitName() == "golem_datadriven" then
		caster:Stop()
	end
end

function color_unit( unit )
	name = unit:GetUnitName()
	if name == "money_farm" then
		unit:SetRenderColor(255, 255, 0)
	elseif name == "invisible_farm" then
		unit:SetRenderColor(0, 174, 255)
	elseif name == "upgraded_farm" then
		unit:SetRenderColor(255, 100, 100)
	elseif name == "strong_farm" then
		unit:SetRenderColor(125, 125, 125)
	end
end

function level1_abilities(keys)
	for i,v in ipairs(LEVEL2_ABILITIES) do
		keys.caster:RemoveAbility(v)
	end
	for i,v in ipairs(LEVEL1_ABILITIES) do
		keys.caster:AddAbility(v)
		if v == "build_stack_farm" and keys.caster:HasModifier("modifier_shepherd_antistack") then
			keys.caster:FindAbilityByName(v):SetLevel(0)
		else
			keys.caster:FindAbilityByName(v):SetLevel(1)
		end
	end
end

function level2_abilities(keys)
	for i,v in ipairs(LEVEL1_ABILITIES) do
		keys.caster:RemoveAbility(v)
	end
	for i,v in ipairs(LEVEL2_ABILITIES) do
		keys.caster:AddAbility(v)
		keys.caster:FindAbilityByName(v):SetLevel(1)
	end
end

function upgrade(keys)
	local name = keys.ability:GetAbilityName()
	local tower = keys.caster

	tower:Upgrade()
end

function sellback( keys )
	keys.caster:SellBack()
end

function self_destruct( keys )
	--TODO: this won't remove the farm from keys.caster.farms.
	BuildingHelper:RemoveBuilding(keys.caster, true)
end

function delete_last_farm( keys )
	local cast = keys.caster
	print("Deleting last placed for pID:" .. cast:GetPlayerID())
	remove_farms(cast, true)
end

function destory_all_farms( keys )
	local cast = keys.caster
	print("Destroying all farms for pID:" .. cast:GetPlayerID())
	remove_farms(cast, false)
end

function remove_farms( cast , bool, exclude, farm )
	exclude = exclude or false
	farm = farm or 'money_farm'

	-- ensure the table has entries
	while #cast.farms > 0 do
		local ent = cast.farms[1]
		if IsValidEntity(ent) and ent:IsAlive() and not ent:IsNull() then
			-- we found the first valid farm.
			if exclude and ent:GetUnitName() == farm then
				-- do nothing
			else
				BuildingHelper:RemoveBuilding(ent, true)
			end
			if bool then
				break;
			end
		else
			-- this farm was already destroyed with self_destruct ability.
			-- it should not be in this table, so clean it up now.
			table.remove(cast.farms, 1)
			ScoreBoard:Update( {key="PLAYER", ID=cast:GetPlayerID() , panel={ "Farms" }, paneltext={ #cast.farms }})
		end
	end
end

function save_sheep( keys )
	if keys.target:GetUnitName() == "npc_dota_hero_wisp" then
		print("Sheep Saved!")
		keys.target:ForceKill(false)
		Notifications:TopToAll({text="A sheep has been saved!", duration=3.0})
	end
end

function make_invis( keys )
	-- contruction_animation(keys.caster, 5)
	keys.caster:SetRenderColor(0, 174, 255)
	keys.caster:RemoveAbility("make_invis")
	keys.caster:AddAbility("invisible")
	keys.caster:FindAbilityByName("invisible"):SetLevel(1)
end

function frost_farm_upgrade( keys )
	print('Upgrade to Frost Farm')
	UpgradeBuilding( keys )
end

function magic_farm_upgrade( keys )
	print('Upgrade to Magic Farm')
	UpgradeBuilding( keys )
end

function farm_upgrade_interrupted( keys )
	print('Upgrade interrupted.')
	local caster = keys.caster
	if caster == nil or caster:GetPlayerOwner() == nil then
		return
	end
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local refund = keys.Refund

	hero:ModifyGold(refund, false, 0)
end

function money_farm_income( keys )
	--print(keys.income)
	if keys.caster == nil or keys.caster:GetPlayerOwner() == nil then
		return nil
	end

	local gold = keys.income

	PopupNumbers(keys.caster, "gold", Vector(255,200,33), 1.0, gold, '#', nil)
	keys.caster:GetPlayerOwner():GetAssignedHero():ModifyGold(gold,false,0)
end

function contruction_animation( unit, duration )
	ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf", PATTACH_RENDERORIGIN_FOLLOW, unit)
	Timers:CreateTimer(duration, function()
		StopEffect(unit, "particles/econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf")
	end)
end

--[[
	Author: Noya
	Date: 17.01.2015.
	Gives vision over an area and shows a particle to the team
]]
function far_sight( event )
	print('Far Sight Cast')
	local caster = event.caster
	local ability = event.ability
	local level = ability:GetLevel()
	local reveal_radius = ability:GetLevelSpecialValueFor( "radius", level - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", level - 1 )

	local allHeroes = HeroList:GetAllHeroes()
	local particleName = "particles/items_fx/dust_of_appearance.vpcf"
	local target = event.target_points[1]

	-- Particle for team
	for _, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_WORLDORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, target )
			ParticleManager:SetParticleControl( fxIndex, 1, Vector(reveal_radius,0,reveal_radius) )
		end
	end

	-- Sound dummy unit
	local dummy = CreateUnitByName("npc_dummy_unit", target, true, caster, nil, caster:GetTeam())
	dummy:AddNewModifier(dummy, nil, "modifier_dummy_unit", {})
	EmitSoundOnLocationForAllies(dummy:GetAbsOrigin(), "DOTA_Item.DustOfAppearance.Activate", caster)

	Timers:CreateTimer(duration, function()
		dummy:RemoveSelf()
	end)

	-- Vision
	if level == 1 then
		AddFOWViewer(caster:GetTeamNumber(), target, reveal_radius, duration, false)
    end
end

function mirror_image_start ( keys )
	print('Mirror Image Cast')
	keys.caster:Stop()
	keys.caster:AddNewModifier(keys.caster, nil, "modifier_shepherd_illusion_begin", {})
	keys.caster:AddNoDraw()

	local caster = keys.caster
	local mirrorimage = caster.mirrorimage or {}
	for _,unit in pairs(mirrorimage) do	
	if unit and IsValidEntity(unit) then
		unit:ForceKill(true)
		end
	end
	-- Reset table
	caster.mirrorimage = {}

	local caster = keys.caster
	local player_id = caster:GetPlayerID()
	local team = caster:GetTeam()
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = 150
	ang_right = QAngle(0, -60, 0)
	ang_left = QAngle(0, 60, 0)
	local front_position = origin + fv * distance
	point_left = RotatePosition(origin, ang_left, front_position)
	point_right = RotatePosition(origin, ang_right, front_position)
	local positions = {}
		table.insert(positions, point_left)
		table.insert(positions, point_right)
	local rand = math.random(1,2)
	local rand2 = 1
	if rand == 1 then
		rand2 = 2
	end
	print(rand)

	for i,v in ipairs(positions) do
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( particle, 1, v )
	end

	Timers:CreateTimer( keys.delay, function()
		mirror_image( keys, positions, rand, rand2)
	end)
end

function mirror_image ( keys, positions, rand, rand2)
	print('Mirror Image Finish')
	local illusion_duration = keys.duration
	local illusion_outgoing_damage = -100
	local illusion_incoming_damage = 0

	local caster = keys.caster
	local player_id = caster:GetPlayerID()
	local team = caster:GetTeam()
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()

	local directionCaster = (positions[rand2] - origin):Normalized()
	local directionIllusion = (positions[rand] - origin):Normalized()

	--[[ ============================================================================================================
		Author: Rook, with help from Noya
		Date: February 2, 2015
		Returns a reference to a newly-created illusion unit.
	================================================================================================================= ]]
	-- Create illusion
	local illusion = CreateUnitByName(caster:GetUnitName(), positions[rand], true, caster, nil, team)
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = keys.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
		end
	end

	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	illusion:MakeIllusion()
	illusion:SetHealth(caster:GetHealth())
	illusion:SetMana(caster:GetMana())
	illusion:SetForwardVector(fv)
	illusion:SetHullRadius(32)
	FindMirrorImageSpace(illusion, positions[rand], 500, directionIllusion)
	illusion:Stop()

	--local r1 = FindClearSpaceForUnit(illusion, positions[rand], true)
	--[[
	local newPos1 = FindGoodSpaceForUnit( illusion, positions[rand], 1800, nil )
	if newPos1 ~= false then
		FindClearSpaceForUnit(illusion, newPos1, true)
	end
	]]

	-- Add to caster to find later
	table.insert(caster.mirrorimage, illusion)

	--caster:SetAbsOrigin(positions[rand2])
	caster:RemoveModifierByName("modifier_shepherd_illusion_begin")
	caster:Stop()
	FindMirrorImageSpace(caster, positions[rand2], 500, directionCaster)
	--local r2 = FindClearSpaceForUnit(caster, positions[rand2], true)
	--print(r1, r2)
	--[[
	local newPos2 = FindGoodSpaceForUnit( caster, positions[rand2], 1800, nil )
	if newPos2 ~= false then
		FindClearSpaceForUnit(caster, newPos2, true)
	end
	]]
	caster:RemoveNoDraw()


	print(illusion:IsIllusion())
end

-- This function drives the FindBigSpaceForUnit function in a line
function FindMirrorImageSpace( unit, vTargetPos, speed, direction )
	local nTickRate = 1/30
	local nIncrement = speed * nTickRate
	local vCheckSpace = vTargetPos
	local iteration = 0
	local iterationMax = 300
	Timers:CreateTimer(nTickRate, function()
		print(iteration, speed, nTickRate, nIncrement, direction, vCheckSpace)
		if FindBigSpaceForUnit(unit, vCheckSpace) then
			return nil
		else
			iteration = iteration + 1
			vCheckSpace = vCheckSpace + (direction * nIncrement)
		end
		if iteration == iterationMax then -- Out of bounds
			FindClearSpaceForUnit(unit, vTargetPos, true)
			return nil
		end
		return nTickRate
	end)
end


function place_sentry ( keys )
	print('Sentry Placed')
	local point = keys.target_points[1]
	local caster = keys.caster
	local team = caster:GetTeamNumber()
	CreateUnitByName("sentry_ward_datadriven", point, true, nil, nil, team)
end

function sentry_placed ( keys )
	local caster = keys.caster
	local target = keys.target
	EmitSoundOnLocationForAllies(target:GetAbsOrigin(), "DOTA_Item.SentryWard.Activate", caster)
	local particle = ParticleManager:CreateParticleForTeam("particles/items2_fx/ward_spawn_generic.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, caster:GetTeamNumber())
end

function remove_player_control ( keys )
	local target = keys.target
	target:SetControllableByPlayer(-1, false)
end

function antistack_on ( keys )
	print('Antistack On')
	local target = keys.target
	local ability = target:FindAbilityByName("build_stack_farm")
	if ability then
		ability:SetLevel(0)
	end
end

function antistack_off ( keys )
	print('Antistack Off')
	local target = keys.target
	local ability = target:FindAbilityByName("build_stack_farm")
	if ability then
		ability:SetLevel(1)
	end
end

-- ITEMS
function potion_of_strength( keys )
	print('Potion of Strength Attack')
end

function beam_of_strength( keys )
	print('Beam of Strength')
	-- init ability
	local caster = keys.caster
	local ability = keys.ability

	local radius = keys.radius
	local proj_speed = keys.proj_speed
	local distance = keys.range

	local casterOrigin = caster:GetAbsOrigin()
	local targetDirection = caster:GetForwardVector()
	local projVelocity = targetDirection * proj_speed

	local startTime = GameRules:GetGameTime()
	local endTime = startTime + 3

	-- Create linear projectile
	local projID = ProjectileManager:CreateLinearProjectile( {
		Ability = ability,
		EffectName = keys.proj_particle,
		vSpawnOrigin = casterOrigin,
		fDistance = distance,
		fStartRadius = radius,
		fEndRadius = radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC,
		fExpireTime = endTime,
		bDeleteOnHit = true,
		vVelocity = projVelocity,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	} )
end

function beam_of_strength_hit( keys )
	print('Beam of Strength: Hit')
	local target = keys.target
	local caster = keys.Source
	local ability = keys.Ability

	target:Kill(ability, caster)
end

function potion_of_mana( keys )
	print('Potion of Mana')
	--[[
	local particle = ParticleManager:CreateParticle("particles/items2_fx/magic_wand.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:SetParticleControl( particle, 0, keys.target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, Vector(50,0,0) )
	]]
	keys.target:SetMana(keys.target:GetMaxMana())
end

function sheep_locator( keys )
	print('Locate Sheeps')
	local caster = keys.caster
	if #Sheeps > 0 then
		for i,v in ipairs(Sheeps) do
			if not v:IsNull() and v:GetUnitName() == "npc_dota_hero_riki" and v:IsAlive() then
				MinimapEvent(caster:GetTeamNumber(), v, v:GetAbsOrigin()[1], v:GetAbsOrigin()[2], DOTA_MINIMAP_EVENT_HINT_LOCATION, 2)
			end
		end
	end
end

function get_golem_summon_point ( keys )
	local caster = keys.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local point = origin + fv * 200
	local result = {}
		table.insert(result, point)
	return result
end

function set_unit_forward( keys )
	local caster = keys.caster
	local target = keys.target
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	target:SetForwardVector(fv)
end

function bomber( keys )
	local target = keys.target_points[1]
	local caster = keys.caster

	local bomber_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(bomber_particle_effect, 0, Vector(target[1], target[2], 1500 + target[3] - 128))
	ParticleManager:SetParticleControl(bomber_particle_effect, 1, Vector(target[1], target[2], -1800 + target[3] - 128))
	ParticleManager:SetParticleControl(bomber_particle_effect, 2, Vector(0.6, 0, 0))
end

-- Modifiers
function farm_death( keys )
	if keys.attacker:GetUnitName() ~= "npc_dota_hero_riki" then
		farm_bounty(keys)
	end

    if keys.caster.buildingSplat then
        ParticleManager:DestroyParticle(keys.caster.buildingSplat, true)
    end

	EmitSoundOn("Building_Tombstone.Destruction", keys.caster)
	local particle = ParticleManager:CreateParticle("particles/dire_fx/bad_barracks_destruction_fire2.vpcf", PATTACH_ABSORIGIN, keys.attacker)
	ParticleManager:SetParticleControl( particle, 0, keys.caster:GetAbsOrigin())
	local particle2 = ParticleManager:CreateParticle("particles/sun_strike/invoker_sun_strike_ground.vpcf", PATTACH_ABSORIGIN, keys.attacker)
	ParticleManager:SetParticleControl( particle2, 0, keys.caster:GetAbsOrigin())

	BuildingHelper:RemoveBuilding(keys.caster, true)
end

function farm_bounty( keys )
	local farm = keys.caster
	local name = keys.caster:GetUnitName()
	local shep = keys.attacker
	local bounty = 0

	if name == "normal_farm" then
		bounty = 1
	elseif name == "tiny_farm" then
		if farm:HasModifier("modifier_invisible") then
			bounty = 4
		else
			bounty = 1
		end
	elseif name == "hard_farm" then
		if farm:HasModifier("modifier_invisible") then
			bounty = 5
		else
			bounty = 2
		end
	elseif name == "wide_farm" then
		if farm:HasModifier("modifier_invisible") then
			bounty = 5
		else
			bounty = 2
		end
	elseif name == "invisible_farm" then
		bounty = 3
	elseif name == "magic_farm" then
		bounty = 4
	elseif name == "money_farm" then
		bounty = 4
	elseif name == "upgraded_farm" then
		bounty = 2
	elseif name == "strong_farm" then
		bounty = 3
	elseif name == "stack_farm" then
		bounty = 6
	elseif name == "sentry_farm" then
		bounty = 4
	elseif name == "aura_farm" then
		bounty = 4
	elseif name == "frost_farm" then
		bounty = 4
	end

	if shep:HasModifier("modifier_item_mining_scythe") then
		bounty = (bounty * 2) + 1
	end
	print(bounty)
	PopupNumbers(shep, "gold", Vector(255,200,33), 1.0, bounty, '#', nil)
	shep:GetPlayerOwner():GetAssignedHero():ModifyGold(bounty,false,0)
end

function shepherd_pregame_create( keys )
	local target = keys.target
	target:SetDayTimeVisionRange(0)
	target:SetNightTimeVisionRange(0)
end

function shepherd_pregame_destroy( keys )
	local target = keys.target
	target:SetDayTimeVisionRange(1800)
	target:SetNightTimeVisionRange(1800)
end

function debug_teleport( keys )
	print(keys.target_points[1])
	FindClearSpaceForUnit(keys.caster, keys.target_points[1], true)
end

function test( keys )
	print('test')
end