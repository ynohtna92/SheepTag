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
	[1] = "build_aura_farm",
	[2] = "build_strong_farm",
	--[3] = "build_wide_farm",
	[3] = "build_sentry_farm",
	[4] = "build_savings_farm",
	[5] = "build_invisible_farm",
	[6] = "level1_abilities",
}
--[[
function build( keys )
	local point = keys.target_points[1]
	local farm = nil
	local name = keys.ability:GetAbilityName()
	if name == "build_normal_farm" then
		farm = Farm:NormalFarm(point, keys.caster)
	elseif name == "build_tiny_farm" then
		farm = Farm:TinyFarm(point, keys.caster)
	elseif name == "build_hard_farm" then
		farm = Farm:HardFarm(point, keys.caster)
	elseif name == "build_upgraded_farm" then
		farm = Farm:UpgradedFarm(point, keys.caster)
	elseif name == "build_stack_farm" then
		farm = Farm:StackFarm(point, keys.caster)
	elseif name == "build_aura_farm" then
		farm = Farm:AuraFarm(point, keys.caster)
	elseif name == "build_strong_farm" then
		farm = Farm:StrongFarm(point, keys.caster)
	elseif name == "build_wide_farm" then
		farm = Farm:WideFarm(point, keys.caster)
	elseif name == "build_savings_farm" then
		farm = Farm:SavingsFarm(point, keys.caster)
	elseif name == "build_invisible_farm" then
		farm = Farm:InvisibleFarm(point, keys.caster)
	end

	if farm == nil or not farm.buildSuccess then
		return
	end

	table.insert(keys.caster.farms, 1, farm)

	-- Valid farm at this point.
	if farm.think then
		farm:Think()
	end
end
]]

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

		FindClearSpaceForUnit(keys.caster, keys.caster:GetAbsOrigin(), true)

		-- start the building with 0 mana.
		unit:SetMana(0)

		-- Custom for this map
		color_unit(unit)
		table.insert(keys.caster.farms, 1, unit)
		Timers:CreateTimer(0, function()
			local point = unit:GetAbsOrigin()
			local gridNavBlocker = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = point})

			unit.blocker = gridNavBlocker	
			unit:SetAbsOrigin(point)			
		end)

	end)
	keys:OnConstructionCompleted(function(unit)
		if Debug_BH then
			print("Completed construction of " .. unit:GetUnitName())
		end
		-- Play construction complete sound.
		-- Give building its abilities
		InitAbilities(unit)
		-- add the mana
		--unit:SetMana(unit:GetMaxMana())
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

	-- ensure the table has entries

	while #cast.farms > 0 do
		local ent = cast.farms[1]
		if IsValidEntity(ent) and ent:IsAlive() then
			-- we found the first valid farm.
			print("Deleting last placed for pID:" .. cast:GetPlayerID())
			ent:RemoveBuilding(true)
			table.remove(cast.farms, 1)
			break;
		else
			-- this farm was already destroyed with self_destruct ability.
			-- it should not be in this table, so clean it up now.
			table.remove(cast.farms, 1)
		end
	end
end

function save_sheep( keys )
	
end

function make_invis( keys )
	-- contruction_animation(keys.caster, 5)
	keys.caster:SetRenderColor(0, 174, 255)
	keys.caster:RemoveAbility("make_invis")
	keys.caster:AddAbility("invisible")
	keys.caster:FindAbilityByName("invisible"):SetLevel(1)
end

function frost_farm_upgrade( keys )
	
end

function money_farm_income( keys )
	print(keys.income)
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

function debug_teleport( keys )
	print(keys.target_points[1])
	FindClearSpaceForUnit(keys.caster, keys.target_points[1], true)
end