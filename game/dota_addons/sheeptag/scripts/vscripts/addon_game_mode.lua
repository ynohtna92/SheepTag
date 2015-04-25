-- module_loader by Adynathos.
BASE_MODULES = {
	'util', 
	'timers',
	'buildinghelper',
	'physics',
	'FlashUtil',
	'farm',
	'abilities',
	'sheeptag',
}

local function load_module(mod_name)
	-- load the module in a monitored environment
	local status, err_msg = pcall(function()
		require(mod_name)
	end)

	if status then
		log(' module ' .. mod_name .. ' OK')
	else
		err(' module ' .. mod_name .. ' FAILED: '..err_msg)
	end
end

-- Load all modules
for i, mod_name in pairs(BASE_MODULES) do
	load_module(mod_name)
end

function Precache( context )
	--[[
		This function is used to precache resources/units/items/abilities that will be needed
		for sure in your game and that cannot or should not be precached asynchronously or 
		after the game loads.

		See SheepTag:PostLoadPrecache() in sheeptag.lua for more information
		]]

		print("[SHEEPTAG] Performing pre-load precache")

		PrecacheResource("particle_folder", "particles/buildinghelper", context)

		-- Particles can be precached individually or by folder
		-- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
		PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
		PrecacheResource("particle", "particles/econ/wards/portal/ward_portal_core/ward_portal_eye_sentry.vpcf", context)
		PrecacheResource("particle_folder", "particles/econ/items/tinker/boots_of_travel", context)
		PrecacheResource("particle", "particles/econ/wards/f2p/f2p_ward/ward_true_sight.vpcf", context)
		PrecacheResource( "particle", "particles/items2_fx/smoke_of_deceit_buff.vpcf", context )
		PrecacheResource( "particle", "particles/msg_fx/msg_gold.vpcf", context )
	
		-- Models can also be precached by folder or individually
		-- PrecacheModel should generally used over PrecacheResource for individual models
		PrecacheResource("model_folder", "particles/heroes/antimage", context)
		PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
		PrecacheModel("models/heroes/viper/viper.vmdl", context)
		PrecacheModel("models/courier/defense3_sheep/defense3_sheep.mdl", context)
		PrecacheModel("models/props_structures/good_barracks_melee001.vmdl", context)
		PrecacheModel("models/buildings/building_racks_ranged_reference.vmdl", context)
		PrecacheModel("models/buildings/building_racks_melee_reference.vmdl", context)
		PrecacheModel("models/props_structures/bad_statue001.vmdl", context)
		PrecacheModel("models/props_structures/good_statue010.vmdl", context)
		PrecacheModel("models/heroes/undying/undying_tower.vmdl", context)
		PrecacheModel("models/items/hex/sheep_hex/sheep_hex.vmdl", context)
		PrecacheModel("models/props_gameplay/sheep01.vmdl", context)

		Farm:Precache(context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.SheepTag = SheepTag()
	GameRules.SheepTag:InitSheepTag()
end
