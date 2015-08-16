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

-- The following three functions are necessary for building helper.
function build( keys )
	local player = keys.caster:GetPlayerOwner()
	local pID = player:GetPlayerID()

	-- Check if player has enough resources here. If he doesn't they just return this function.
	
	local returnTable = BuildingHelper:AddBuilding(keys)

	keys:OnBuildingPosChosen(function(vPos)
		--print("OnBuildingPosChosen")
		-- in WC3 some build sound was played here.
	end)

	keys:OnConstructionStarted(function(unit)

		if Debug_BH then
			print("Started construction of " .. unit:GetUnitName())
		end
		-- Unit is the building be built.
		-- Play construction sound
		-- FindClearSpace for the builder

		FindClearSpaceForUnit(keys.caster, keys.caster:GetAbsOrigin(), false)

		-- Break Sheep Invis
		keys.caster:RemoveModifierByName("modifier_invisibility_datadriven")

		-- This modifier will delete the farm, manage particle effects when it dies.
		GiveUnitDataDrivenModifier(unit, unit, "modifier_farm_death_datadriven", -1)

		-- start the building with 0 mana.
		unit:SetMana(0)

		-- Custom for this map
		color_unit(unit)
		table.insert(keys.caster.farms, 1, unit)
		name = unit:GetUnitName()
		-- One tick later this will happen
		if name ~= "tiny_farm" then
			Timers:CreateTimer(0, function()
				if name == "hard_farm" or name == "wide_farm" then
					local origin = unit:GetAbsOrigin()
					local size = 64
					if name == "wide_farm" then
						size = 32
					end
						
					local points = { Vector(origin.x-size, origin.y-size, origin.z),
						Vector(origin.x-size, origin.y+size, origin.z),
						Vector(origin.x+size, origin.y-size, origin.z),
						Vector(origin.x+size, origin.y+size, origin.z)
					}

					unit.blocker = {}
					for i=1,#points do
						local obstruction = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = points[i]})
						unit.blocker[i] = obstruction
					end
					unit:SetAbsOrigin(origin)
				else
					local point = unit:GetAbsOrigin()
					local gridNavBlocker = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = point})
					unit.blocker = {}
					unit.blocker[1] = gridNavBlocker	
					unit:SetAbsOrigin(point)
				end		
			end)
		end
	end)
	keys:OnConstructionCompleted(function(unit)
		if Debug_BH then
			print("Completed construction of " .. unit:GetUnitName())
		end

		-- Remove Health Bar
		Timers:CreateTimer(0, function()
			GiveUnitDataDrivenModifier(unit, unit, "modifier_farm_built_datadriven", -1)
		end)

		-- Play construction complete sound.
		-- Give building its abilities
		InitAbilities(unit)
		-- add the mana
		unit:SetMana(unit:GetMaxMana())
	end)

	-- These callbacks will only fire when the state between below half health/above half health changes.
	-- i.e. it won't unnecessarily fire multiple times.
	keys:OnBelowHalfHealth(function(unit)
		if Debug_BH then
			print(unit:GetUnitName() .. " is below half health.")
		end
	end)

	keys:OnAboveHalfHealth(function(unit)
		if Debug_BH then
			print(unit:GetUnitName() .. " is above half health.")
		end
	end)

	--[[keys:OnCanceled(function()
		print(keys.ability:GetAbilityName() .. " was canceled.")
	end)]]

	-- Have a fire effect when the building goes below 50% health.
	-- It will turn off it building goes above 50% health again.
	keys:EnableFireEffect("modifier_jakiro_liquid_fire_burn")
end

function building_canceled( keys )
	BuildingHelper:CancelBuilding(keys)
end

function create_building_entity( keys )
	BuildingHelper:InitializeBuildingEntity(keys)
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
		keys.caster:FindAbilityByName(v):SetLevel(1)
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

	keys.caster:RemoveBuilding(true)
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
		if IsValidEntity(ent) and ent:IsAlive() then
			-- we found the first valid farm.
			if exclude and ent:GetUnitName() == farm then
				-- do nothing
			else
				ent:RemoveBuilding(true)
				table.remove(cast.farms, 1)
			end
			if bool then
				break;
			end
		else
			-- this farm was already destroyed with self_destruct ability.
			-- it should not be in this table, so clean it up now.
			table.remove(cast.farms, 1)
		end
	end
end

function save_sheep( keys )
	if keys.target:GetUnitName() == "npc_dota_hero_wisp" then
	print("Sheep Saved!")
		keys.target:ForceKill(false)
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
end

function magic_farm_upgrade( keys )
	print('Upgrade to Magic Farm')
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

	-- Sound
	caster:EmitSound("DOTA_Item.DustOfAppearance.Activate")

	-- Vision
	if level == 1 then
		AddFOWViewer(caster:GetTeamNumber(), target, reveal_radius, duration, false)
    end
end

function mirror_image_start ( keys )
	print('Mirror Image Cast')
	keys.caster:Stop()
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
	FindClearSpaceForUnit(illusion, positions[rand], true)

	-- Add to caster to find later
	table.insert(caster.mirrorimage, illusion)

	--caster:SetAbsOrigin(positions[rand2])
	caster:Stop()
	FindClearSpaceForUnit(caster, positions[rand2], true)
	caster:RemoveNoDraw()


	print(illusion:IsIllusion())
end

function place_sentry ( keys )
	print('Sentry Placed')
	local point = keys.target_points[1]
	local caster = keys.caster
	local team = caster:GetTeamNumber()
	CreateUnitByName("sentry_ward_datadriven", point, true, nil, nil, team)
end

function remove_player_control ( keys )
	local target = keys.target
	target:SetControllableByPlayer(-1, false)
end

-- ITEMS
function potion_of_strength( keys )
	print('Potion of Strength Attack')
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

	EmitSoundOn("Building_Tombstone.Destruction", keys.caster)
	local particle = ParticleManager:CreateParticle("particles/dire_fx/bad_barracks_destruction_fire2.vpcf", PATTACH_ABSORIGIN, keys.attacker)
	ParticleManager:SetParticleControl( particle, 0, keys.caster:GetAbsOrigin())
	local particle2 = ParticleManager:CreateParticle("particles/sun_strike/invoker_sun_strike_ground.vpcf", PATTACH_ABSORIGIN, keys.attacker)
	ParticleManager:SetParticleControl( particle2, 0, keys.caster:GetAbsOrigin())

	keys.caster:RemoveBuilding(true)
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