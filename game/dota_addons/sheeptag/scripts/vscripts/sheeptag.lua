--[[
Last modified: 18/08/2015
Author: A_Dizzle
Co-Author: Myll
]]

print ('[SHEEPTAG] sheeptag.lua' )

DEBUG = true
THINK_TIME = 0.1

VERSION = "B180815"

-- Game Variables
STARTING_GOLD = 0
ROUND_TIME = 600
SHEPHERD_GOLD_TICK_TIME = 60
SHEPHERD_GOLD_PER_TICK = 20
SHEPHERD_SPAWN = 10
SHEEP_GOLD_TICK_TIME = 1
SHEEP_GOLD_PER_TICK = 1
SHEEP_GOLD_BOUNTY = 30

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 30.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                       -- How much gold should players get per tick?
GOLD_TICK_TIME = 0                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1500.0        -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                    -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = true      -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = false    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false               -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 1                           -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

FORCE_PICKED_HERO = "npc_dota_hero_riki"  -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = i * 100
end

-- Generated from template
if SheepTag == nil then
  --print ( '[SHEEPTAG] creating sheeptag game mode' )
  SheepTag = class({})
end

--[[
  This function should be used to set up Async precache calls at the beginning of the game.  The Precache() function 
  in addon_game_mode.lua used to and may still sometimes have issues with client's appropriately precaching stuff.
  If this occurs it causes the client to never precache things configured in that block.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).
]]
function SheepTag:PostLoadPrecache()
  print("[SHEEPTAG] Performing Post-Load precache")
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_riki", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_lycan", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_wisp", function(...) end)
  --PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitSheepTag() but needs to be done before everyone loads in.
]]
function SheepTag:OnFirstPlayerLoaded()
--print("[SHEEPTAG] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function SheepTag:OnAllPlayersLoaded()
--print("[SHEEPTAG] All Players have loaded into the game")
end

-- Store teams, players and heroes
function SheepTag:HeroInit( hero )
  local pID = hero:GetPlayerID()
  self.vPlayerIDToHero[pID] = hero
  if self.vPlayers[pID] ~= nil then
    return
  end
  self.vPlayers[pID] = pID
  --print('TeamNumber: '..hero:GetTeamNumber())
  if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
    table.insert(self.vRadiant, pID)
  elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
    table.insert(self.vDire, pID)
  end
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function SheepTag:OnHeroInGame(hero)
  --print("[SHEEPTAG] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- Game Starts for the first time! Run Once!
  if not self.initStuff then
    self:RevealMap(30)
    Timers:CreateTimer(4, function()
      GameRules:SendCustomMessage("<b>Welcome to Sheep Tag!</b> [".. VERSION .. "]", 0, 0)
      GameRules:SendCustomMessage("Main Developer & Mapper: <font color='#FF1493'>A_Dizzle</font>", 0, 0)
      GameRules:SendCustomMessage("Co-Developers: <font color='#FF1493'>Myll</font> (Coder)", 0, 0)
      GameRules:SendCustomMessage("WC3 Developers: <font color='#FF1493'>Chakra</font>, <font color='#FF1493'>XXXandBEER</font>, <font color='#FF1493'>GosuSheep</font> and lastly <font color='#FF1493'>Star[MD]</font>.", 0, 0)
      GameRules:SendCustomMessage("Special Thanks: <font color='#FF1493'>BMD</font>, <font color='#FF1493'>Noya</font> & <font color='#FF1493'>Jacklarnes</font> and everyone on IRC", 0, 0)
      GameRules:SendCustomMessage("Support this project on Github at https://github.com/ynohtna92/SheepTag", 0, 0)
    end)

    Timers:CreateTimer(5, function()
      local msg = {
        message = "Warm up",
        duration = 4.0
      }
      FireGameEvent("show_center_message",msg)
    end)

    Timers:CreateTimer(10, function()
      local msg = {
        message = "The game will begin in 20 seconds",
        duration = 4.0
      }
      FireGameEvent("show_center_message",msg)
    end)

    self.initStuff = true
  end

  if hero.player == nil then
    print ("hero.player is nil.")
  end

  ShowGenericPopupToPlayer(hero.player, "#sheeptag_instructions_title", "#sheeptag_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
 
  local id = hero:GetPlayerID()

  local spawnid = id + 1
  if spawnid > 5 then
    spawnid = spawnid - 5
  end 
 -- print(id, spawnid)

  PlayerResource:SetCameraTarget(id, hero)

  local heroName = hero:GetUnitName()
  if heroName == "npc_dota_hero_wisp" then -- Dead Sheep
    hero:SetAbilityPoints(0)
    hero:FindAbilityByName("sheep_spirit"):SetLevel(1)
    Timers:CreateTimer(0.1,function()
      PlayerResource:SetCameraTarget(id, nil)
    end)
  elseif heroName == "npc_dota_hero_riki" then -- Sheep
    Timers:CreateTimer(function()
      local spawnpoint = SpawnPointsSheep[spawnid]
      hero:SetAbsOrigin( spawnpoint:GetAbsOrigin() )
      FindClearSpaceForUnit(hero, spawnpoint:GetAbsOrigin(), false)
      hero:SetForwardVector( spawnpoint:GetForwardVector() )
      Timers:CreateTimer(0.1,function()
        PlayerResource:SetCameraTarget(id, nil)
      end)
    end)

    InitAbilities(hero)

    table.insert(Sheeps, hero)

    hero.farms = {}
    hero:SetHullRadius(10)

    -- This line for example will set the starting gold of every hero to 500 unreliable gold
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
      hero:SetGold(99999, false)
    end
    --hero:SetMinimumGoldBounty( SHEEP_GOLD_BOUNTY )
    --hero:SetMaximumGoldBounty( SHEEP_GOLD_BOUNTY )

    -- These lines will create an item and add it to the player, effectively ensuring they start with the item
    local item = CreateItem("item_delete_last_farm", hero, hero)
    hero:AddItem(item)

    local item = CreateItem("item_save_sheep", hero, hero)
    hero:AddItem(item)

    local item = CreateItem("item_destroy_all_farms", hero, hero)
    hero:AddItem(item)

    local item = CreateItem("item_build_aura_farm", hero, hero)
    hero:AddItem(item)
  elseif heroName == "npc_dota_hero_lycan" and id ~= -1 then -- Shepherd
    InitAbilities(hero)

    Timers:CreateTimer(function()
      local spawnpoint = SpawnPointsShepherd[spawnid]
      hero:SetAbsOrigin( spawnpoint:GetAbsOrigin() )
      hero:SetForwardVector( spawnpoint:GetForwardVector() )
      Timers:CreateTimer(0.1,function()
        PlayerResource:SetCameraTarget(id, nil)
      end)
    end)

    table.insert(Shepherds, hero)

    hero:SetHullRadius(32) -- A hull radius of 32 will make pathing do weird things.
  end

  -- Remove Wearables
  if heroName == "npc_dota_hero_riki" or heroName == "npc_dota_hero_lycan" then
    --print('Removing Wearables')
    hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
    hero.hiddenWearables = {} 
    local wearable = hero:FirstMoveChild()
    while wearable ~= nil do
     --print(wearable:GetClassname())     
     if wearable:GetClassname() == "dota_item_wearable" then
        local modelName = wearable:GetModelName()
        if string.find(modelName, "invisiblebox") == nil then
          -- Add the original model name to revert later
          table.insert(hero.wearableNames,modelName)
          --print("Hidden "..modelName.."")

          -- Set model invisible
          wearable:SetModel("models/development/invisiblebox.vmdl")
          table.insert(hero.hiddenWearables,wearable)
        end
      end
      wearable = wearable:NextMovePeer()
      if model ~= nil then
        --print("Next Peer:" .. wearable:GetModelName())
      end
    end
  end
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function SheepTag:OnGameInProgress()
  print("[SHEEPTAG] The game has officially begun")
  self:ClearLevel()
  self:HideAllHeroes()
  Timers:CreateTimer(2,function()
    self:ResetRound()
    self:StartRound()
  end)
end

-- Cleanup a player when they leave
function SheepTag:OnDisconnect(keys)
  --print('[SHEEPTAG] Player Disconnected ' .. tostring(keys.userid))
  --PrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function SheepTag:OnGameRulesStateChange(keys)
  --print("[SHEEPTAG] GameRules State Changed")
  --PrintTable(keys)

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    local et = 6
    if self.bSeenWaitForPlayers then
      et = .01
    end
    Timers:CreateTimer("alljointimer", {
      useGameTime = true,
      endTime = et,
      callback = function()
        if PlayerResource:HaveAllPlayersJoined() then
          SheepTag:PostLoadPrecache()
          SheepTag:OnAllPlayersLoaded()
          return
        end
        return 1
      end
    })
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    SheepTag:OnGameInProgress()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function SheepTag:OnNPCSpawned(keys)
  --print("[SHEEPTAG] NPC Spawned")
  --PrintTable(keys)
  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    SheepTag:OnHeroInGame(npc)
    SheepTag:HeroInit(npc)
  end 

  if npc:GetUnitName() == "golem_datadriven" then
    npc:SetHullRadius(33)
    print('Golem Spawn')
  end
  --print(npc:GetClassname())
end

-- An item was picked up off the ground
function SheepTag:OnItemPickedUp(keys)
  --print ( '[SHEEPTAG] OnItemPurchased' )
  --PrintTable(keys)

  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function SheepTag:OnPlayerReconnect(keys)
--print ( '[SHEEPTAG] OnPlayerReconnect' )
--PrintTable(keys)
end

-- An item was purchased by a player
function SheepTag:OnItemPurchased( keys )
  --print ( '[SHEEPTAG] OnItemPurchased' )
  --PrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname

  -- The cost of the item purchased
  local itemcost = keys.itemcost

end

-- An ability was used by a player
function SheepTag:OnAbilityUsed(keys)
  --print('[SHEEPTAG] AbilityUsed')
  --PrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local abilityname = keys.abilityname

  -- Cancel the ghost if the player casts another active ability.
  -- Start of BH Snippet:
  if player.cursorStream ~= nil then
    if not (string.len(abilityname) > 14 and string.sub(abilityname,1,14) == "move_to_point_") then
      if not DontCancelBuildingGhostAbils[abilityname] then
        player:CancelGhost()
      else
        print(abilityname .. " did not cancel building ghost.")
      end
    end
  end
  -- End of BH Snippet
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function SheepTag:OnNonPlayerUsedAbility(keys)
  --print('[SHEEPTAG] OnNonPlayerUsedAbility')
  --PrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function SheepTag:OnPlayerChangedName(keys)
  --print('[SHEEPTAG] OnPlayerChangedName')
  --PrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function SheepTag:OnPlayerLearnedAbility( keys)
  --print ('[SHEEPTAG] OnPlayerLearnedAbility')
  --PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function SheepTag:OnAbilityChannelFinished(keys)
  --print ('[SHEEPTAG] OnAbilityChannelFinished')
  --PrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function SheepTag:OnPlayerLevelUp(keys)
  --print ('[SHEEPTAG] OnPlayerLevelUp')
  --PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function SheepTag:OnLastHit(keys)
  --print ('[SHEEPTAG] OnLastHit')
  --PrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A tree was cut down by tango, quelling blade, etc
function SheepTag:OnTreeCut(keys)
  --print ('[SHEEPTAG] OnTreeCut')
  --PrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function SheepTag:OnRuneActivated (keys)
  --print ('[SHEEPTAG] OnRuneActivated')
  --PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function SheepTag:OnPlayerTakeTowerDamage(keys)
  --print ('[SHEEPTAG] OnPlayerTakeTowerDamage')
  --PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function SheepTag:OnPlayerPickHero(keys)
  --print ('[SHEEPTAG] OnPlayerPickHero')
  --PrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function SheepTag:OnTeamKillCredit(keys)
  --print ('[SHEEPTAG] OnTeamKillCredit')
  --PrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function SheepTag:OnEntityKilled( keys )
  --print( '[SHEEPTAG] OnEntityKilled Called' )
  --PrintTable( keys )

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:GetUnitName() == "npc_dota_hero_riki" then
    --[[
    if killerEntity:GetUnitName() == "npc_dota_hero_lycan" then
      local bounty = killedUnit:GetGoldBounty()
      local pID = killerEntity:GetPlayerOwnerID()
      local hero = self.vPlayerIDToHero[pID]
      if hero ~= nil then
        hero:ModifyGold(bounty, false, 0)
      end
    end
    ]]
    BuildingHelper:ClearQueue(killedUnit)
    self:OnSheepKilled(killedUnit)
  elseif killedUnit:GetUnitName() == "npc_dota_hero_wisp" then
    self:OnWispKilled(killedUnit)
  end

  -- Building Killed BUILDINGHELPER
  if killedUnit:IsNull() then
    return
  end
  if IsCustomBuilding(killedUnit) then
    local particle = ParticleManager:CreateParticle("particles/world_destruction_fx/base_statue_destruction_generic_c.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(particle,0 , killedUnit:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    killedUnit:AddNoDraw()
  end
  -- Put code here to handle when an entity gets killed
end

function SheepTag:ModifyGoldFilter( event )
  --PrintTable(event)
  if event.reason_const == DOTA_ModifyGold_HeroKill then
    event.reliable = 0
    if event.gold ~= 30 then
      return false
    else
      return true
    end
  end
end

-- Called whenever a player changes its current selection, it keeps a list of entity indexes
function SheepTag:OnPlayerSelectedEntities( event )
  local pID = event.pID

  GameRules.SELECTED_UNITS[pID] = event.selected_entities

  -- This is for Building Helper to know which is the currently active builder
  local mainSelected = GetMainSelectedEntity(pID)
  if IsValidEntity(mainSelected) and IsBuilder(mainSelected) then
    local player = PlayerResource:GetPlayer(pID)
    player.activeBuilder = mainSelected
  end
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function SheepTag:InitSheepTag()
  SheepTag = self
  --print('[SHEEPTAG] Starting to load SheepTag gamemode...')

  -- Setup rules
  GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
  GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
  GameRules:SetPreGameTime( PRE_GAME_TIME)
  GameRules:SetPostGameTime( POST_GAME_TIME )
  GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
  GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
  GameRules:SetGoldPerTick(GOLD_PER_TICK)
  GameRules:SetGoldTickTime(GOLD_TICK_TIME)
  GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes( true )
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
  --print('[SHEEPTAG] GameRules set')

  GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(SheepTag, "ModifyGoldFilter"), self)
  GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(SheepTag, "FilterExecuteOrder"), self)

  GameRules:GetGameModeEntity():SetStashPurchasingDisabled(true)

  InitLogFile( "log/sheeptag.txt","")

  -- Event Hooks
  -- All of these events can potentially be fired by the game, though only the uncommented ones have had
  -- Functions supplied for them.  If you are interested in the other events, you can uncomment the
  -- ListenToGameEvent line and add a function to handle the event
  ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(SheepTag, 'OnPlayerLevelUp'), self)
  ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(SheepTag, 'OnAbilityChannelFinished'), self)
  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(SheepTag, 'OnPlayerLearnedAbility'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(SheepTag, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(SheepTag, 'OnConnectFull'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(SheepTag, 'OnDisconnect'), self)
  ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(SheepTag, 'OnItemPurchased'), self)
  ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(SheepTag, 'OnItemPickedUp'), self)
  ListenToGameEvent('last_hit', Dynamic_Wrap(SheepTag, 'OnLastHit'), self)
  ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(SheepTag, 'OnNonPlayerUsedAbility'), self)
  ListenToGameEvent('player_changename', Dynamic_Wrap(SheepTag, 'OnPlayerChangedName'), self)
  ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(SheepTag, 'OnRuneActivated'), self)
  ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(SheepTag, 'OnPlayerTakeTowerDamage'), self)
  ListenToGameEvent('tree_cut', Dynamic_Wrap(SheepTag, 'OnTreeCut'), self)
  --ListenToGameEvent('entity_hurt', Dynamic_Wrap(SheepTag, 'OnEntityHurt'), self)
  ListenToGameEvent('player_connect', Dynamic_Wrap(SheepTag, 'PlayerConnect'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(SheepTag, 'OnAbilityUsed'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(SheepTag, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(SheepTag, 'OnNPCSpawned'), self)
  ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(SheepTag, 'OnPlayerPickHero'), self)
  ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(SheepTag, 'OnTeamKillCredit'), self)
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(SheepTag, 'OnPlayerReconnect'), self)
  --ListenToGameEvent('player_spawn', Dynamic_Wrap(SheepTag, 'OnPlayerSpawn'), self)
  --ListenToGameEvent('dota_unit_event', Dynamic_Wrap(SheepTag, 'OnDotaUnitEvent'), self)
  --ListenToGameEvent('nommed_tree', Dynamic_Wrap(SheepTag, 'OnPlayerAteTree'), self)
  --ListenToGameEvent('player_completed_game', Dynamic_Wrap(SheepTag, 'OnPlayerCompletedGame'), self)
  --ListenToGameEvent('dota_match_done', Dynamic_Wrap(SheepTag, 'OnDotaMatchDone'), self)
  --ListenToGameEvent('dota_combatlog', Dynamic_Wrap(SheepTag, 'OnCombatLogEvent'), self)
  --ListenToGameEvent('dota_player_killed', Dynamic_Wrap(SheepTag, 'OnPlayerKilled'), self)
  --ListenToGameEvent('player_team', Dynamic_Wrap(SheepTag, 'OnPlayerTeam'), self)

    -- Register Listener
  CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(SheepTag, 'OnPlayerSelectedEntities'))
  CustomGameEventManager:RegisterListener( "repair_order", Dynamic_Wrap(SheepTag, "RepairOrder"))   
  CustomGameEventManager:RegisterListener( "building_helper_build_command", Dynamic_Wrap(BuildingHelper, "BuildCommand"))
  CustomGameEventManager:RegisterListener( "building_helper_cancel_command", Dynamic_Wrap(BuildingHelper, "CancelCommand"))

  Convars:RegisterCommand('player_say', function(...)
    local arg = {...}
    table.remove(arg,1)
    local sayType = arg[1]
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    keys = {}
    keys.ply = cmdPlayer
    keys.teamOnly = false
    keys.text = table.concat(arg, " ")

    if (sayType == 4) then
      -- Student messages
    elseif (sayType == 3) then
      -- Coach messages
    elseif (sayType == 2) then
      -- Team only
      keys.teamOnly = true
      -- Call your player_say function here like
      self:PlayerSay(keys)
    else
      -- All chat
      -- Call your player_say function here like
      self:PlayerSay(keys)
    end
  end, 'player say', 0)

  -- Fill server with fake clients
  -- Fake clients don't use the default bot AI for buying items or moving down lanes and are sometimes necessary for debugging
  Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')

      Timers:CreateTimer('assign_fakes', {
        useGameTime = false,
        endTime = Time(),
        callback = function(sheeptag, args)
          local userID = 20
          for i=0, 9 do
            userID = userID + 1
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
                self:OnConnectFull({
                  userid = userID,
                  index = ply:entindex()-1
                })

                ply:GetAssignedHero():SetControllableByPlayer(0, true)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)

  -- Change random seed
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  -- Initialized tables for tracking state
  self.vUserIds = {}
  self.vSteamIds = {}
  self.vBots = {}
  self.vBroadcasters = {}

  self.vPlayerIDToHero = {}
  self.vPlayers = {}
  self.nPlayerCount = 0
  self.vRadiant = {}
  self.vDire = {}

  self.nRadiantKills = 0
  self.nDireKills = 0

  self.bSeenWaitForPlayers = false

  self.nGameRunning = false

  self.center = Entities:FindByName(nil, "spawn_center")

  self.roundTimer = nil
  self.goldSheepTimer = nil
  self.goldShepherdTimer = nil

  self.RadiantSheep = true

  self.fowReveal = {}
  self.fowReveal[1] = { 0, 0 }
  self.fowReveal[2] = { 3000, 0 }
  self.fowReveal[3] = { -3000, 0 }
  self.fowReveal[4] = { 0, 3000 }
  self.fowReveal[5] = { 0, -3000 }
  self.fowReveal[6] = { 3000, 3000 }
  self.fowReveal[7] = { -3000, -3000 }
  self.fowReveal[8] = { -3000, 3000 }
  self.fowReveal[9] = { 3000, -3000 }
  self.fowReveal[10] = { 6000, 0 }
  self.fowReveal[11] = { -6000, 0 }
  self.fowReveal[12] = { 0, 6000 }
  self.fowReveal[13] = { 0, -6000 }
  self.fowReveal[14] = { 6000, 6000 }
  self.fowReveal[15] = { -6000, -6000 }
  self.fowReveal[16] = { -6000, 6000 }
  self.fowReveal[17] = { 6000, -6000 }
  self.fowReveal[18] = { 3000, 6000 }
  self.fowReveal[19] = { 3000, -6000 }
  self.fowReveal[20] = { -3000, 6000 }
  self.fowReveal[21] = { -3000, -6000 }
  self.fowReveal[22] = { 6000, 3000 }
  self.fowReveal[23] = { 6000, -3000 }
  self.fowReveal[24] = { -6000, 3000 }
  self.fowReveal[25] = { -6000, -3000 }

  Sheeps = {}
  Shepherds = {}

  SpawnPointsSheep = {}
  SpawnPointsShepherd = {}

  for i=1,5 do
    table.insert(SpawnPointsSheep, Entities:FindByName(nil, "sheep_start_" .. i))
    table.insert(SpawnPointsShepherd, Entities:FindByName(nil, "shep_start_" .. i))
  end

  --SendToServerConsole( "dota_wearables_clientside 1" )
  --SendToServerConsole( "dota_combine_models 0" )

  -- BH Snippet

  -- Full units file to get the custom values
  GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  GameRules.Requirements = LoadKeyValues("scripts/kv/tech_tree.kv")

    -- Store and update selected units of each pID
  GameRules.SELECTED_UNITS = {}

  -- Keeps the blighted gridnav positions
  GameRules.Blight = {}

  --BuildingHelper:Init() --2688
  --BuildingHelper:BlockRectangularArea(Vector(-192,-192,0), Vector(192,192,0))

  --print('[SHEEPTAG] Done loading SheepTag gamemode!\n\n')
end

mode = nil

-- This function is called as the first player loads and sets up the SheepTag parameters
function SheepTag:CaptureSheepTag()
  if mode == nil then
    -- Set SheepTag parameters
    mode = GameRules:GetGameModeEntity()

    -- Hide some HUD elements
    --mode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_HEROES, false)
    mode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_SCOREBOARD, false)
    mode:SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_COURIER, false) -- no courier
    --mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED ) BROKEN use entry below
    mode:SetHUDVisible( DOTA_HUD_VISIBILITY_SHOP_SUGGESTEDITEMS, false ) 
    --mode:SetHUDVisible(8, false)
    mode:SetTopBarTeamValuesOverride( USE_CUSTOM_TOP_BAR_VALUES )

    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
    mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
    mode:SetBuybackEnabled( BUYBACK_ENABLED )
    mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
    mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
    if FORCE_PICKED_HERO ~= nil then
      mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
    end

    --mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

    --mode:SetFogOfWarDisabled( DISABLE_FOG_OF_WAR_ENTIRELY )
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
    mode:SetLoseGoldOnDeath( false )

    self:OnFirstPlayerLoaded()
  end
end

-- This function is called 1 to 2 times as the player connects initially but before they
-- have completely connected
function SheepTag:PlayerConnect(keys)
  --print('[SHEEPTAG] PlayerConnect')
  --PrintTable(keys)

  if keys.bot == 1 then
    -- This user is a Bot, so add it to the bots table
    self.vBots[keys.userid] = 1
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function SheepTag:OnConnectFull(keys)
  --print ('[SHEEPTAG] OnConnectFull')
  --PrintTable(keys)
  SheepTag:CaptureSheepTag()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)

  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()

  -- Update the user ID table with this user
  table.insert(self.vUserIds, ply)

  -- Update the Steam ID table
  self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

  -- If the player is a broadcaster flag it in the Broadcasters table
  if PlayerResource:IsBroadcaster(playerID) then
    self.vBroadcasters[keys.userid] = 1
    return
  end
end

function SheepTag:PlayerSay(keys)
  --print ('[SHEEPTAG] PlayerSay')
  --PrintTable(keys)

  local ply = keys.ply
  local plyID = ply:GetPlayerID()
  local hero = ply:GetAssignedHero()
  local txt = keys.text
  local args = split(txt, " ")

  print(plyID, txt)

  if keys.teamOnly then
    -- This text was team-only
  end

  if txt == nil or txt == "" then
    return
  end

  if DEBUG and string.find(keys.text, "^-gold") then
    print("Giving gold to player")
    for k,v in pairs(HeroList:GetAllHeroes()) do
      v:SetGold(50000, false)
      GameRules:SetUseUniversalShopMode( true )
    end
  end

  -- Player Commands

  if string.find(keys.text, "^-unstuck") or string.find(keys.text, "^-u") then
    FindClearSpaceForUnit(hero, hero:GetAbsOrigin(), true)
  end

  if args[1] == "-buy" then
    if args[2] ~= nil then
      CommandBuy(hero, args[2])
    end
  end

  if args[1] == "-sell" then
    if args[2] ~= nil then
      CommandSell(hero, args[2])
    end
  end

  if args[1] == "-sellall" then
    CommandSellAll(hero)
  end

  if args[1] == "-g" then
    if args[2] ~= nil then
      CommandGive(hero, args[2], args[3])
    end
  end
  
  if args[1] == "-d" then
    CommandDestroy(hero)
  end

  if args[1] == "-ds" then
    CommandDestroyExclude(hero)
  end

  if args[1] == "-end" then
    Timers:CreateTimer(3, function()
      GameRules:SetGameWinner(hero:GetTeam())
      GameRules:SetSafeToLeave( true )
    end)
    self.EndMessage()
  end

  if args[1] == "-kill" then
    hero:ForceKill(false)
  end

  if args[1] == "-unstuck" then
    FindClearSpaceForUnit(hero, hero:GetAbsOrigin(), false)
  end

  if string.find(keys.text, "^-time") then
    FireGameEvent('cgm_timer_display', { timerMsg = "Remaining", timerSeconds = 12, timerWarning = 10, timerEnd = true, timerPosition = 0})
  end

  if args[1] == "-testend" then
    self:EndRound(true)
  end

  if args[1] == "-teststart" then
    self:StartRound()
  end
  --[[
  if string.find(keys.text, "^-reset") and plyID == 0 then
    GameMode:ResetGame()
  end
  ]]
end

function SheepTag:StartRound( )
  -- Start Gold Tickers
  if self.goldSheepTimer == nil then
    self.goldSheepTimer = Timers:CreateTimer(function()
      if #Sheeps > 0 then
        for _,v in ipairs(Sheeps) do
          v:ModifyGold(SHEEP_GOLD_PER_TICK, false, DOTA_ModifyGold_GameTick)
        end
      end
      return SHEEP_GOLD_TICK_TIME
    end)
  end

  if self.goldShepherdTimer == nil then
    self.goldShepherdTimer = Timers:CreateTimer(function()
      if #Shepherds > 0 then
        for _,v in ipairs(Shepherds) do
          v:ModifyGold(SHEPHERD_GOLD_PER_TICK, false, DOTA_ModifyGold_GameTick)
        end
      end
      return SHEPHERD_GOLD_TICK_TIME
    end)
  end

  FireGameEvent('cgm_timer_display', { timerMsg = "Wolves Spawn", timerSeconds = 15, timerWarning = 5, timerEnd = true, timerPosition = 0})
  print(#Shepherds)
  for _,v in ipairs(Shepherds) do
    v:AddNoDraw()
    v:AddAbility('shepherd_pregame')
    v:FindAbilityByName("shepherd_pregame"):SetLevel(1)
  end
  Timers:CreateTimer(15, function()
    for _,v in ipairs(Shepherds) do
      v:RemoveNoDraw()
      v:RemoveAbility('shepherd_pregame')
      v:RemoveModifierByName('modifier_shepherd_pregame')
    end
    GameRules:SendCustomMessage("The wolves have been set free!", 0, 0)
    FireGameEvent('cgm_timer_display', { timerMsg = "Remaining", timerSeconds = 600, timerWarning = 30, timerEnd = false, timerPosition = 0})
    self.roundTimer = Timers:CreateTimer(600, function()
      self:EndRound(true)
    end)
  end)
end

function SheepTag:CheckRoundEnd( )
  local bEnd = true
  if #Sheeps > 0 then
    for i,v in ipairs(Sheeps) do
      if not v:IsNull() and v:IsAlive() then
        bEnd = false
      end
    end
  end

  if bEnd then
    self:EndRound(false)
  end
end

function SheepTag:EndRound( sheeporwolf ) -- 1 Sheep win, 0 wolves win
  if sheeporwolf then -- sheep win
    GameRules:SendCustomMessage("<font color='#32CD32'>Time's up! The sheep win!</font>", 0, 0)
  else -- wolves win
    GameRules:SendCustomMessage("<font color='#DC143C'>All sheep have been killed! The shepherds win!</font>", 0, 0)
    if self.roundTimer ~= nil then
      Timers:RemoveTimer(self.roundTimer)
      self.roundTimer = nil
      -- End Timer
      FireGameEvent('cgm_timer_display', { timerMsg = "Remaining", timerSeconds = 0, timerWarning = 10, timerEnd = false, timerPosition = 0})
    end
  end
  if self.goldSheepTimer ~= nil then
    Timers:RemoveTimer(self.goldSheepTimer)
    self.goldSheepTimer = nil
  end
  if self.goldShepherdTimer ~= nil then
    Timers:RemoveTimer(self.goldShepherdTimer)
    self.goldShepherdTimer = nil
  end

  if self.RadiantSheep and sheeporwolf then -- Team score update
    self.nRadiantKills = self.nRadiantKills + 1
  elseif not self.RadiantSheep and sheeporwolf then
    self.nDireKills = self.nDireKills + 1
  elseif self.RadiantSheep and not sheeporwolf then
    self.nDireKills = self.nDireKills + 1
  else
    self.nRadiantKills = self.nRadiantKills + 1
  end
  GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantKills )
  GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireKills )
  self:ClearLevel()
  self:HideAllHeroes()
  self:RevealMap(10)
  Timers:CreateTimer(6, function()
    self:SwapTeams()
  end)
  Timers:CreateTimer(10, function()
    self:ResetRound()
    self:StartRound()
  end)
end

function SheepTag:ClearLevel() -- Cleanup
  -- Remove all farms
  if #Sheeps > 0 then
    for _,v in ipairs(Sheeps) do
      BuildingHelper:ClearQueue(v)
      remove_farms(v, false)
    end
  end
  -- Remove all wards
  local wards = Entities:FindAllByClassname('npc_dota_ward_base_truesight')
  print(#wards)
  if #wards > 0 then
    for _,v in ipairs(wards) do
      UTIL_Remove(v)
    end
  end
  -- Remove all shepherd spawned units
  local golem = Entities:FindAllByClassname('npc_dota_warlock_golem')
  if #golem > 0 then
    for _,v in ipairs(golem) do
      UTIL_Remove(v)
    end
  end
  -- Remove all dropped items
  for i=1,GameRules:NumDroppedItems() do
    local item = GameRules:GetDroppedItem(0) -- Delete last place dropped item
    UTIL_Remove(item)
  end
  SendToConsole('dota_camera_set_lookatpos 0 -500')
end

function SheepTag:RevealMap( duration )
  for i,v in ipairs(self.fowReveal) do
    AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(v[1],v[2],128), 15000, duration, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(v[1],v[2],128), 15000, duration, false)
  end
end

function SheepTag:HideAllHeroes()
  for i,v in ipairs(self.vRadiant) do
    local hero = PlayerResource:GetSelectedHeroEntity( v )
    hero:AddNoDraw()
    hero:AddAbility('shepherd_pregame')
    hero:FindAbilityByName("shepherd_pregame"):SetLevel(1)
  end
  for i,v in ipairs(self.vDire) do
    local hero = PlayerResource:GetSelectedHeroEntity( v )
    hero:AddNoDraw()
    hero:AddAbility('shepherd_pregame')
    hero:FindAbilityByName("shepherd_pregame"):SetLevel(1)
  end
end

function SheepTag:ShowAllHeroes()
  for _,v in ipairs(self.vRadiant) do
    local hero = PlayerResource:GetSelectedHeroEntity( v )
    hero:RemoveNoDraw()
    hero:RemoveAbility('shepherd_pregame')
    hero:RemoveModifierByName('modifier_shepherd_pregame')
  end
  for _,v in ipairs(self.vDire) do
    local hero = PlayerResource:GetSelectedHeroEntity( v )
    hero:RemoveNoDraw()
    hero:RemoveAbility('shepherd_pregame')
    hero:RemoveModifierByName('modifier_shepherd_pregame')
  end
end

function SheepTag:ResetRound()
  local oldHero = nil
  local newHero = nil
  local heroRadiant = "npc_dota_hero_riki"
  local heroDire = "npc_dota_hero_lycan"
  if not self.RadiantSheep then
    heroRadiant = "npc_dota_hero_lycan"
    heroDire = "npc_dota_hero_riki"
  end
  Sheeps = {}
  Shepherds = {}
  print(#self.vRadiant)
  for _,v in ipairs(self.vRadiant) do
    --print('Radiant: ' .. v)
    oldHero = PlayerResource:GetSelectedHeroEntity( v )
    -- Remove items from inventory
    for i=0,11 do
      local item = oldHero:GetItemInSlot(i)
      if item then
        oldHero:RemoveItem(item)
      end
    end
    PlayerResource:ReplaceHeroWith( v, heroRadiant, STARTING_GOLD, 0)
    UTIL_Remove( oldHero )
  end
  for _,v in ipairs(self.vDire) do
    --print('Dire: ' .. v)
    oldHero = PlayerResource:GetSelectedHeroEntity( v )
    -- Remove items from inventory
    for i=0,11 do
      local item = oldHero:GetItemInSlot(i)
      if item then
        oldHero:RemoveItem(item)
      end
    end
    PlayerResource:ReplaceHeroWith( v, heroDire, STARTING_GOLD, 0)
    UTIL_Remove( oldHero )
  end
end

function SheepTag:SwapTeams()
  Timers:CreateTimer(function()
    local msg = {
      message = "Swapping teams",
      duration = 3.0
    }
    FireGameEvent("show_center_message",msg)
  end)
  self.RadiantSheep = not self.RadiantSheep
end

function SheepTag:OnSheepKilled( hero )
  local gold = hero:GetGold()
  local plyID = hero:GetPlayerID()
  local oldHero = self.vPlayerIDToHero[plyID]

  remove_farms(oldHero, false)

  PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_wisp", STARTING_GOLD, 0)
  local index = GetIndex(Sheeps, oldHero)
  if index ~= -1 then
    table.remove(Sheeps, index)
  end
  UTIL_Remove( oldHero )
  local newHero = self.vPlayerIDToHero[plyID]
  FindClearSpaceForUnit(newHero, Entities:FindByName(nil, "spawn_center"):GetAbsOrigin(), false)
  newHero:SetGold( gold, false )
  self:CheckRoundEnd()
end

function SheepTag:OnWispKilled( hero )
  local gold = hero:GetGold()
  local plyID = hero:GetPlayerID()
  local oldHero = self.vPlayerIDToHero[plyID]
  PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_riki", STARTING_GOLD, 0)
  local newHero = self.vPlayerIDToHero[plyID]
  local id = plyID + 1
  if plyID > 5 then
    id = plyID - 5
  end
  local spawn = SpawnPointsSheep[id]
  FindClearSpaceForUnit( newHero, spawn:GetAbsOrigin(), false )
  newHero:SetForwardVector( spawn:GetForwardVector() )
  newHero:SetGold( gold, false )
  Timers:CreateTimer(2, function()
    UTIL_Remove( oldHero )    
  end)
end

function SheepTag:EndMessage()
  GameRules:SendCustomMessage("Thank you for playing Sheep Tag!", 0, 0)
  GameRules:SendCustomMessage("<font color='#7FFF00'>Remember to share your feedback on the Workshop Page</font>.", 0, 0)
  GameRules:SendCustomMessage("https://github.com/ynohtna92/SheepTag", 0, 0)
  GameRules:SendCustomMessage(" ", 0, 0)
end
