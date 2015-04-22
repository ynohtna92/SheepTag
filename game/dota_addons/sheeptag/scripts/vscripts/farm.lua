FarmModels = 
{
	[1] = "models/props_structures/good_statue008.vmdl",
	[2] = "",
	[3] = "",
	[4] = "",
	[5] = "",
	[6] = "",
}

if Farm == nil then
  Farm = {}
end

function Farm:new(vPoint, nSize, hOwner, sBuilding, nBuildTime, fScale, sModel)
	local point = BuildingHelper:AddBuildingToGrid(vPoint, nSize, hOwner)
	if point ~= -1 then
		local farm = CreateUnitByName(sBuilding, point, false, nil, nil, hOwner:GetTeam())
		if sModel ~= nil then
			Timers:CreateTimer(function()
				farm:SetModel(sModel)
				BuildingHelper:AddBuilding(farm)
				farm:UpdateHealth(nBuildTime,true,fScale)
			end)
		else
			BuildingHelper:AddBuilding(farm)
			farm:UpdateHealth(nBuildTime,true,fScale)
		end
		return farm
		
	else
		return nil
	end

	function farm:SellBack()
		farm:RemoveBuilding(true)
	end
end

function Farm:NormalFarm(vPoint, hOwner)
	local normalFarm = Farm:new(vPoint, 2, hOwner, "normal_farm", .4, .7, nil)
	if normalFarm ~= nil then
		normalFarm.buildSuccess = true
	else
		return
	end
	normalFarm:FindAbilityByName("self_destruct"):SetLevel(1)

	return normalFarm
end

function Farm:TinyFarm( vPoint, hOwner )
	local tinyFarm = Farm:new(vPoint, 1, hOwner, "tiny_farm", 2.0, .8, nil)
	if tinyFarm ~= nil then
		tinyFarm.buildSuccess = true
	else
		return
	end
	tinyFarm:FindAbilityByName("self_destruct"):SetLevel(1)
	tinyFarm:FindAbilityByName("make_invis"):SetLevel(1)

	return tinyFarm
end

function Farm:HardFarm( vPoint, hOwner )
	local hardFarm = Farm:new(vPoint, 3, hOwner, "hard_farm", 2.0, .8, nil)
	if hardFarm ~= nil then
		hardFarm.buildSuccess = true
	else
		return
	end

	return hardFarm
end

function Farm:UpgradedFarm( vPoint, hOwner )
	local upgradedFarm = Farm:new(vPoint, 3, hOwner, "upgraded_farm", 2.0, .8, nil)
	if upgradedFarm ~= nil then
		upgradedFarm.buildSuccess = true
	else
		return
	end

	return upgradedFarm
end

function Farm:StackFarm( vPoint, hOwner )
	local stackFarm = Farm:new(vPoint, 3, hOwner, "stack_farm", 2.0, .8, nil)
	if stackFarm ~= nil then
		stackFarm.buildSuccess = true
	else
		return
	end

	return stackFarm
end

function Farm:AuraFarm( vPoint, hOwner )
	local auraFarm = Farm:new(vPoint, 3, hOwner, "aura_farm", 2.0, .8, nil)
	if auraFarm ~= nil then
		auraFarm.buildSuccess = true
	else
		return
	end

	return normalFarm
end

function Farm:StrongFarm( vPoint, hOwner )
	local strongFarm = Farm:new(vPoint, 3, hOwner, "strong_farm", 2.0, .8, nil)
	if strongFarm ~= nil then
		strongFarm.buildSuccess = true
	else
		return
	end

	return normalFarm
end

function Farm:WideFarm( vPoint, hOwner )
	local wideFarm = Farm:new(vPoint, 3, hOwner, "wide_farm", 2.0, .8, nil)
	if wideFarm ~= nil then
		wideFarm.buildSuccess = true
	else
		return
	end

	return normalFarm
end

function Farm:SavingsFarm( vPoint, hOwner )
	local savingsFarm = Farm:new(vPoint, 3, hOwner, "savings_farm", 2.0, .8, nil)
	if savingsFarm ~= nil then
		savingsFarm.buildSuccess = true
	else
		return
	end

	return normalFarm
end

function Farm:InvisibleFarm( vPoint, hOwner )
	local invisibleFarm = Farm:new(vPoint, 3, hOwner, "invisible_farm", 2.0, .8, nil)
	if invisibleFarm ~= nil then
		invisibleFarm.buildSuccess = true
	else
		return
	end

	return normalFarm
end

function Farm:Precache( context )
	for i,v in ipairs(FarmModels) do
		PrecacheModel(v, context)
	end
end