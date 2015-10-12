shopItems = {
	['golem'] = {140, 'item_golem'},
	['cloak'] = {200, 'item_cloak_of_flames'},
	['endur'] = {112, 'item_endurance_aura'},
	['bril'] = {98, 'item_brilliance_aura'},
	['drums'] = {190, 'item_war_drums'},
	['bomber'] = {75, 'item_bomber'},
	['speed'] = {35, 'item_potion_of_speed'},
	['str']	= {42, 'item_potion_of_strength'},
	['sheep'] = {56, 'item_sheep_locator'},
	['mana'] = {49, 'item_potion_of_mana'},
	['beam'] = {112, 'item_potion_of_strength'},
	['c16'] = {53, 'item_claws_16'},
	['c45'] = {200, 'item_claws_45'},
	['scythe'] = {58, 'item_mining_scythe'},
	['neck'] = {112, 'item_necklace_of_invulnerability'},
	['sobi'] = {56, 'item_sobi_mask2'},
	['gem'] = {91, 'item_gem_of_seeing'},
	['ball'] = {28, 'item_crystal_ball'},
	['boots'] = {112, 'item_boots_of_speed'},
	['velocity'] = {112, 'item_recipe_claws_of_velocity'}, -- 424
	['r90']	= {112, 'item_recipe_claws_of_attack'}, -- 512
	['gloves'] = {112, 'item_gloves_of_haste'},
}

function CommandBuy ( hero , args )
	print('BUY: ' .. args)
	if shopItems[args] then
		if hero:GetGold() >= shopItems[args][1] then
			if hero:HasRoomForItem(shopItems[args][2], false, false) ~= 4 then
				hero:SpendGold( shopItems[args][1], DOTA_ModifyGold_PurchaseItem)
				local item = CreateItem(shopItems[args][2], hero, hero)
				hero:AddItem(item)
				EmitSoundOnClient("General.Buy", PlayerResource:GetPlayer(hero:GetPlayerID()))
			else
				SendErrorMessage( hero:GetPlayerID(), "#error_no_inventory_room" )
			end
		else
			SendErrorMessage( hero:GetPlayerID(), "#error_not_enough_gold" )
		end
	else
		SendErrorMessage( hero:GetPlayerID(), "#error_item_missing" )
	end
end

function CommandSell ( hero , args )
	print('SELL: ' .. args)
	local index = tonumber(args)
	if index and index > 0 and index < 7 then
		local item = hero:GetItemInSlot(index - 1) 
		if item then
			hero:ModifyGold(item:GetCost()/3 , false, DOTA_ModifyGold_SellItem)
			hero:RemoveItem(item)
			EmitSoundOnClient("General.Sell", PlayerResource:GetPlayer(hero:GetPlayerID()))
		else
			SendErrorMessage( hero:GetPlayerID(), "#error_item_missing" )
		end
	else
		SendErrorMessage( hero:GetPlayerID(), "#error_syntax_sell" )
	end 
end

function CommandSellAll ( hero )
	print('SELLALL')
	for i=0,5 do
		local item = hero:GetItemInSlot(i) 
		if item then
			hero:ModifyGold(item:GetCost()/3 , false, DOTA_ModifyGold_SellItem)
			hero:RemoveItem(item)
			EmitSoundOnClient("General.Sell", PlayerResource:GetPlayer(hero:GetPlayerID()))
		end
	end
end

function CommandGive ( hero , arg1, arg2 ) -- arg1: player, arg2: gold (optional)
	local id2 = tonumber(arg1)
	if not id2 then
		SendErrorMessage( hero:GetPlayerID(), "#error_syntax_give" )
		return
	end
	local gold = tonumber(arg2)
	local player = PlayerResource:GetPlayer(id2)
	if not player then
		SendErrorMessage( hero:GetPlayerID(), "#error_syntax_give" )
		return
	end
	local hero2 = player:GetAssignedHero()
	if hero2 and hero:GetTeamNumber() == hero2:GetTeamNumber() then
		if gold then
			if gold > 0 and gold <= hero:GetGold() then
				print('GIVE: '..arg1..' '..gold)
				hero:SpendGold( gold, DOTA_ModifyGold_Unspecified)
				hero2:ModifyGold( gold , false, DOTA_ModifyGold_Unspecified)
				Notifications:Bottom(hero:GetPlayerID() , {text="Gave ".. gold .. " gold to " .. PlayerResource:GetPlayerName(id2)..".", style={color='#FFFF00'}, duration=3})
				Notifications:Bottom(hero2:GetPlayerID() , {text="Recieved ".. gold .. " gold from " .. PlayerResource:GetPlayerName(hero:GetPlayerID())..".", style={color='#FFFF00'}, duration=3})
			else
				SendErrorMessage( hero:GetPlayerID(), "#error_not_enough_gold" )
			end
		else
			local all = hero:GetGold()
			if all > 0 then
				print('GIVE: '..arg1)
				hero:SpendGold( all, DOTA_ModifyGold_Unspecified)
				hero2:ModifyGold( all , false, DOTA_ModifyGold_Unspecified)
				Notifications:Bottom(hero:GetPlayerID() , {text="Gave ".. gold .. " gold to " .. PlayerResource:GetPlayerName(id2)..".", style={color='#FFFF00'}, duration=3})
				Notifications:Bottom(hero2:GetPlayerID() , {text="Recieved ".. gold .. " gold from " .. PlayerResource:GetPlayerName(hero:GetPlayerID())..".", style={color='#FFFF00'}, duration=3})
			else
				SendErrorMessage( hero:GetPlayerID(), "#error_not_enough_gold" )
			end
		end
	end
end

function CommandDestroy ( hero )
	print("Destroying all farms for pID:" .. hero:GetPlayerID())
	remove_farms(hero, false)
end

function CommandDestroyExclude ( hero )
	print("Destroying all farms (exception) for pID:" .. hero:GetPlayerID())
	--remove_farms(hero, false, true)
end

function CommandZoom ( hero , arg1, arg2, arg3 )
	local a1 = tonumber(arg1)
	local a2 = tonumber(arg2)
	local a3 = tonumber(arg3)
	local zoomUnit = 1
	if hero:GetUnitName() == "npc_dota_hero_lycan" then
		zoomUnit = 2
	elseif hero:GetUnitName() == "npc_dota_hero_wisp" then
		zoomUnit = 3
	end
	if not a1 and not a2 and not a3 then
		if not SheepTag.vPlayerIDToZoom[hero:GetPlayerID()] then
			SheepTag.vPlayerIDToZoom[hero:GetPlayerID()] = {2400 ,2400 ,2400}
		end
		Notifications:Bottom(hero:GetPlayerID() , {text="Current Zoom: ".. SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][zoomUnit] .." ~ Min Zoom: 1350 ~ Max Zoom: Sheep 2400 | Wolf 2700 | Wisp 3350", style={color='#FFFF00'}, duration=5})
	end
	if a1 and not a2 and not a3 then
		if a1 >= 1350 then
			if a1 > 3350 then
				a3 = 3350
			else
				a3 = a1
			end
			if a1 > 2700 then
				a2 = 2700
			else
				a2 = a1
			end
			if a1 > 2400 then
				a1 = 2400
			end
		else
			a1 = 1350
			a2 = 1350
			a3 = 1350
		end
		print(a1,a2,a3)
		SheepTag.vPlayerIDToZoom[hero:GetPlayerID()] = {a1, a2 ,a3}
		Notifications:Bottom(hero:GetPlayerID() , {text="Zoom Set: ".. SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][1] .. " " .. SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][2] .. " " .. SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][3], style={color='#FFFF00'}, duration=5})
		player = PlayerResource:GetPlayer(hero:GetPlayerID())
		CustomGameEventManager:Send_ServerToPlayer(player, "adjust_zoom", {zoom=SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][zoomUnit]} )	
	elseif a1 and a2 and a3 then
		if a1 < 1350 then
			a1 = 1350
		elseif a1 > 2400 then
			a1 = 2400
		end
		if a2 < 1350 then
			a2 = 1350
		elseif a2 > 2700 then
			a2 = 2700
		end
		if a3 < 1350 then
			a3 = 1350
		elseif a3 > 3350 then
			a3 = 3350
		end
		SheepTag.vPlayerIDToZoom[hero:GetPlayerID()] = {a1, a2 ,a3}
		Notifications:Bottom(hero:GetPlayerID() , {text="Zoom Set: ".. SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][1] .. " " .. SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][2] .. " " .. SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][3], style={color='#FFFF00'}, duration=5})
		player = PlayerResource:GetPlayer(hero:GetPlayerID())
		CustomGameEventManager:Send_ServerToPlayer(player, "adjust_zoom", {zoom=SheepTag.vPlayerIDToZoom[hero:GetPlayerID()][zoomUnit]} )	
	end
end
