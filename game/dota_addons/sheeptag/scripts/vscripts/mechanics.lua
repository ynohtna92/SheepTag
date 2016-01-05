-- Contains general mechanics used extensively thourought different scripts

--[[ Find a clear space for a unit, depending on its HullSize. (Used to replace FindClearSpaceForUnit)
	 Author: space jam
	 Date: 31.07.2015 
	 unit 		 : The handle of the unit you are moving.
	 vTargetPos  : The target Vector you want to move this unit too.
	 searchLimit : The furthest we should look for a clear space.
	 initRadius  : Must be less than searchLimit, allows us to start further out from the initial vector. Can also be nil to not specify.]

	 Example 1: The lua segment of a global blink spell. (KV is just a simple point target ability that runs this.)

	 function SlayerBlink( keys )
	   local caster = keys.caster
	   local ability = keys.ability
	   local point = keys.target_points[1]
	   
	   local newSpace = FindGoodSpaceForUnit(caster, point, 500, nil)
	   if newSpace ~= false then
	     caster:SetAbsOrigin(newSpace)
	   else
	     FireGameEvent('custom_error_show', {player_ID = caster:GetMainControllingPlayer(), _error = "Can't blink there!"})
	     ability:RefundManaCost()
	     ability:EndCooldown()
	   end
	 end]]
function FindGoodSpaceForUnit( unit, vTargetPos, searchLimit, initRadius )
	local startPos = unit:GetAbsOrigin()
	local unitSize = unit:GetHullRadius()
	local gridSize = math.ceil(unitSize / 32)
	local x = vTargetPos.x
	local y = vTargetPos.y

	local goodSpace = {}

	local initBlocked = false
	if initRadius == nil then
		for i=1,360 do
			local rad = math.rad(i)
			local cx = x + unitSize * math.cos(rad)
			local cy = y + unitSize * math.sin(rad)
			local cz = GetGroundPosition(Vector(cx, cy, 1000), unit).z
			local pos = Vector(cx, cy, cz)
	
			-- Check first if the initial space is a good one.	
			local units = FindUnitsInRadius(unit:GetTeam(), pos, nil, unitSize, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			if #units > 0 then
				-- There was a unit other than the unit in that space. Its blocked.
				--DebugDrawCircle(pos, Vector(0,0,255), 1, unitSize, true, 5)
				initBlocked = true
			end
			if GridNav:IsBlocked(pos) or GridNav:IsTraversable(pos) == false then
				initBlocked = true
				--DebugDrawCircle(pos, Vector(255,0,0), 1, unitSize, true, 5)
			end
		end
		-- The inital space was good, return it.
		if initBlocked == false then
			--DebugDrawCircle(vTargetPos, Vector(255,0,0), 1, unitSize, true, 5)
			return vTargetPos
		end
		initRadius = unitSize
	end

	local radius = initRadius
	while radius < searchLimit do
		local isBlocked = false
		local pos = Vector(0, 0, 0)
		local spaceIndex = 1

		-- Draw a circle, find the LEAST blocked space in that circle.
		for i = 1, 360 do
			isBlocked = false
			local rad = math.rad(i)

			-- Start at target point, works its way out.
			local cx = x + radius * math.cos(rad)
			local cy = y + radius * math.sin(rad)

			local cz = GetGroundPosition(Vector(cx, cy, 1000), unit).z
			pos = Vector(cx, cy, cz)
			
			--DebugDrawCircle(Vector(cx, cy, cz), RandomVector(50), 1, unitSize, true, 5)
			if GridNav:IsBlocked(pos) or GridNav:IsTraversable(pos) == false then
				isBlocked = true
				--DebugDrawCircle(pos, Vector(255,0,0), 1, unitSize, true, 5)
			end
			-- We found an empty space, add to current candidate.
			if isBlocked == false then
				if goodSpace[spaceIndex] == nil then goodSpace[spaceIndex] = {} end
				table.insert(goodSpace[spaceIndex], pos) 
			else
				if goodSpace[spaceIndex] ~= nil then
					spaceIndex = spaceIndex + 1
				end
			end
		end

		-- Grab the best candidate.
		local candidate = {}
		for k,v in pairs(goodSpace) do
			-- The table with the most verticies represents the longest unbroken section of clear space in the search radius.
			if #v > #candidate then
				candidate = v
			end
		end

		-- Get the middle point on the candidate space, assume this to be the most likely point to find a clear unit space.
		local bestVec = candidate[math.floor(#candidate / 2)]
		if bestVec ~= nil then
			local validSpace = true
			-- Trace around that point a circle the size of the unit, if we find something the point is blocked.
			for i = 1, 360 do
				local rad = math.rad(i)
	
				local cx = bestVec.x + unitSize * math.cos(rad)
				local cy = bestVec.y + unitSize * math.sin(rad)
				local newVec = Vector(cx, cy, pos.z)
				-- If any point on this circle is blocked, we haven't found a good spot.
				if GridNav:IsBlocked(newVec) or GridNav:IsTraversable(newVec) == false then
					validSpace = false
					DebugDrawCircle(newVec, Vector(0,255,255), 1, unitSize, true, 5)
				end
			end
	
			if validSpace == true then
				local units = FindUnitsInRadius(unit:GetTeam(), bestVec, nil, unitSize, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				DebugDrawCircle(bestVec, Vector(0,255,0), 1, unitSize, true, 5)
				if #units > 0 then
					validSpace = false
				end
				if validSpace == true then
					return bestVec
				end
			end
		end
		radius = radius + unitSize / 4
		DebugDrawCircle(Vector(x, y, pos.z), Vector(255,255,255), 1, radius, true, 5)
	end
	return false			
end

function SendErrorMessage( pID, string )
	Notifications:ClearBottom(pID)
	Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
	EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end

-- Modifies the lumber of this player. Accepts negative values
function ModifyLumber( player, lumber_value )
	if lumber_value == 0 then return end
	if lumber_value > 0 then
		player.lumber = player.lumber + lumber_value
	    CustomGameEventManager:Send_ServerToPlayer(player, "player_lumber_changed", { lumber = math.floor(player.lumber) })
	else
		if PlayerHasEnoughLumber( player, math.abs(lumber_value) ) then
			player.lumber = player.lumber + lumber_value
		    CustomGameEventManager:Send_ServerToPlayer(player, "player_lumber_changed", { lumber = math.floor(player.lumber) })
		end
	end
end

-- Returns Int
function GetGoldCost( unit )
	if unit and IsValidEntity(unit) then
		if unit.GoldCost then
			return unit.GoldCost
		end
	end
	return 0
end

-- Returns Int
function GetLumberCost( unit )
	if unit and IsValidEntity(unit) then
		if unit.LumberCost then
			return unit.LumberCost
		end
	end
	return 0
end

-- Returns float
function GetBuildTime( unit )
	if unit and IsValidEntity(unit) then
		if unit.BuildTime then
			return unit.BuildTime
		end
	end
	return 0
end

function GetCollisionSize( unit )
	if unit and IsValidEntity(unit) then
		if GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] and GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] then
			return GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"]
		end
	end
	return 0
end



-- Returns bool
function PlayerHasEnoughGold( player, gold_cost )
	local hero = player:GetAssignedHero()
	local pID = hero:GetPlayerID()
	local gold = hero:GetGold()

	if gold < gold_cost then
		SendErrorMessage(pID, "#error_not_enough_gold")
		return false
	else
		return true
	end
end

-- Returns bool
function PlayerHasEnoughLumber( player, lumber_cost )
	local pID = player:GetAssignedHero():GetPlayerID()
	if not player.lumber then
		player.lumber = 0
	end

	if player.lumber < lumber_cost then
		SendErrorMessage(pID, "#error_not_enough_lumber")
		return false
	else
		return true
	end
end

-- Returns bool
function PlayerHasResearch( player, research_name )
	if player.upgrades[research_name] then
		return true
	else
		return false
	end
end

-- Returns bool
function PlayerHasRequirementForAbility( player, ability_name )
	local requirements = GameRules.Requirements
	local buildings = player.buildings
	local upgrades = player.upgrades
	local requirement_failed = false

	if requirements[ability_name] then

		-- Go through each requirement line and check if the player has that building on its list
		for k,v in pairs(requirements[ability_name]) do

			-- If it's an ability tied to a research, check the upgrades table
			if requirements[ability_name].research then
				if k ~= "research" and (not upgrades[k] or upgrades[k] == 0) then
					--print("Failed the research requirements for "..ability_name..", no "..k.." found")
					return false
				end
			else
				--print("Building Name","Need","Have")
				--print(k,v,buildings[k])

				-- If its a building, check every building requirement
				if not buildings[k] or buildings[k] == 0 then
					--print("Failed one of the requirements for "..ability_name..", no "..k.." found")
					return false
				end
			end
		end
	end

	return true
end

-- Builders require the "builder" label in its unit definition
function IsBuilder( unit )
	if not IsValidEntity(unit) then
		return
	end
	return (unit:GetUnitLabel() == "builder")
end

function IsCustomBuilding( unit )
    local ability_building = unit:FindAbilityByName("ability_building")
    local ability_tower = unit:FindAbilityByName("ability_tower")
    if ability_building or ability_tower then
        return true
    else
        return false
    end
end

-- A BuildingHelper ability is identified by the "Building" key.
function IsBuildingAbility( ability )
    if not IsValidEntity(ability) then
        return
    end

    local ability_name = ability:GetAbilityName()
    local ability_table = GameRules.AbilityKV[ability_name]
    if ability_table and ability_table["Building"] then
        return true
    else
        ability_table = GameRules.ItemKV[ability_name]
        if ability_table and ability_table["Building"] then
            return true
        end
    end

    return false
end

-- Shortcut for a very common check
function IsValidAlive( unit )
	return (IsValidEntity(unit) and unit:IsAlive())
end

function AddUnitToSelection( unit )
	local player = unit:GetPlayerOwner()
	CustomGameEventManager:Send_ServerToPlayer(player, "add_to_selection", { ent_index = unit:GetEntityIndex() })
end

function RemoveUnitFromSelection( unit )
	local player = unit:GetPlayerOwner()
	local ent_index = unit:GetEntityIndex()
	CustomGameEventManager:Send_ServerToPlayer(player, "remove_from_selection", { ent_index = unit:GetEntityIndex() })
end

function GetSelectedEntities( playerID )
	return GameRules.SELECTED_UNITS[playerID]
end

function IsCurrentlySelected( unit )
	local entIndex = unit:GetEntityIndex()
	local playerID = unit:GetPlayerOwnerID()
	local selectedEntities = GetSelectedEntities( playerID )
	if selectedEntities then
		for _,v in pairs(selectedEntities) do
			if v==entIndex then
				return true
			end
		end
	end
	return false
end

-- Force-check the game event
function UpdateSelectedEntities()
	FireGameEvent("dota_player_update_selected_unit", {})
end

function GetMainSelectedEntity( playerID )
	if GameRules.SELECTED_UNITS[playerID]["0"] then
		return EntIndexToHScript(GameRules.SELECTED_UNITS[playerID]["0"])
	end
	return nil
end

-- ToggleAbility On only if its turned Off
function ToggleOn( ability )
	if ability:GetToggleState() == false then
		ability:ToggleAbility()
	end
end

-- ToggleAbility Off only if its turned On
function ToggleOff( ability )
	if ability:GetToggleState() == true then
		ability:ToggleAbility()
	end
end

function IsMultiOrderAbility( ability )
	if IsValidEntity(ability) and not ability:IsItem() then
		local ability_name = ability:GetAbilityName()
		local ability_table = GameRules.AbilityKV[ability_name]

		if not ability_table then
			ability_table = GameRules.ItemKV[ability_name]
		end

		if ability_table then
			local AbilityMultiOrder = ability_table["AbilityMultiOrder"]
			if AbilityMultiOrder and AbilityMultiOrder == 1 then
				return true
			end
		else
			print("Cant find ability table for "..ability_name)
		end
	end
	return false
end

-- Goes through every ability and item, checking for any ability being channelled
function IsChanneling ( hero )
	
	for abilitySlot=0,15 do
		local ability = hero:GetAbilityByIndex(abilitySlot)
		if ability ~= nil and ability:IsChanneling() then 
			return true
		end
	end

	for itemSlot=0,5 do
		local item = hero:GetItemInSlot(itemSlot)
		if item ~= nil and item:IsChanneling() then
			return true
		end
	end

	return false
end

-- Global item applier
function ApplyModifier( unit, modifier_name )
	local item = CreateItem("item_apply_modifiers", nil, nil)
	item:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
	item:RemoveSelf()
end

-- Removes the first item by name if found on the unit. Returns true if removed
function RemoveItemByName( unit, item_name )
	for i=0,15 do
		local item = unit:GetItemInSlot(i)
		if item and item:GetAbilityName() == item_name then
			item:RemoveSelf()
			return true
		end
	end
	return false
end

-- Takes all items and puts them 1 slot back
function ReorderItems( caster )
	local slots = {}
	for itemSlot = 0, 5, 1 do

		-- Handle the case in which the caster is removed
		local item
		if IsValidEntity(caster) then
			item = caster:GetItemInSlot( itemSlot )
		end

       	if item ~= nil then
			table.insert(slots, itemSlot)
       	end
    end

    for k,itemSlot in pairs(slots) do
    	caster:SwapItems(itemSlot,k-1)
    end
end