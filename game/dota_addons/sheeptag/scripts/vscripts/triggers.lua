function OnStartTouchWisp (trigger)
	if trigger.activator:GetUnitName() == "npc_dota_hero_wisp" then
		FindClearSpaceForUnit(trigger.activator, Entities:FindByName(nil, "spawn_center"):GetAbsOrigin(), false)
		trigger.activator:Stop()
	end
end