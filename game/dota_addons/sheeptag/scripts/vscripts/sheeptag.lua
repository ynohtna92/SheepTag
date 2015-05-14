--[[
Last modified: 02/05/2015
Author: A_Dizzle
Co-Author: Myll
]]

print ('[SHEEPTAG] sheeptag.lua' )

DEBUG = true
THINK_TIME = 0.1

VERSION = "B020515"

-- Game Variables
STARTING_GOLD = 0
ROUND_TIME = 600
SHEPHERD_GOLD_TICK_TIME = 60
SHEPHERD_GOLD_PER_TICK = 20
SHEPHERD_SPAWN = 10
SHEEP_GOLD_TICK_TIME = 1
SHEEP_GOLD_PER_TICK = 1

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 30.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 1                       -- How much gold should players get per tick?
GOLD_TICK_TIME = 1                      -- How long should we wait in seconds between gold ticks?

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
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

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

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function SheepTag:OnHeroInGame(hero)
  --print("[SHEEPTAG] Hero spawned in game for first time -- " .. hero:GetUnitName())

  if not self.initStuff then

    Timers:CreateTimer(4, function()
      GameRules:SendCustomMessage("<b>Welcome to Sheep Tag!</b> [".. VERSION .. "]", 0, 0)
      GameRules:SendCustomMessage("Main Developer & Mapper: <font color='#FF1493'>A_Dizzle</font>", 0, 0)
      GameRules:SendCustomMessage("Co-Developers: <font color='#FF1493'>Myll</font> (Coder)", 0, 0)
      GameRules:SendCustomMessage("WC3 Developers: <font color='#FF1493'>Chakra</font>, <font color='#FF1493'>XXXandBEER</font>, <font color='#FF1493'>GosuSheep</font> and lastly <font color='#FF1493'>Star[MD]</font>.", 0, 0)
      GameRules:SendCustomMessage("Special Thanks: <font color='#FF1493'>BMD, Noya & Jacklarnes</font> and everyone on IRC", 0, 0)
      GameRules:SendCustomMessage("Support this project on Github at https://github.com/ynohtna92/SheepTag", 0, 0)
    end)

    self.initStuff = true
  end

  if hero.player == nil then
    print ("hero.player is nil.")
  end

  ShowGenericPopupToPlayer(hero.player, "#sheeptag_instructions_title", "#sheeptag_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )

  local heroName = hero:GetUnitName()
  if heroName == "npc_dota_hero_wisp" then
    hero:SetAbilityPoints(0)
    hero:FindAbilityByName("sheep_spirit"):SetLevel(1)
  elseif heroName == "npc_dota_hero_riki" then
    InitAbilities(hero)
    
    hero.farms = {}
    hero:SetHullRadius(10)

    -- This line for example will set the starting gold of every hero to 500 unreliable gold
    hero:SetGold(500, false)

    -- These lines will create an item and add it to the player, effectively ensuring they start with the item
    local item = CreateItem("item_delete_last_farm", hero, hero)
    hero:AddItem(item)

    local item = CreateItem("item_save_sheep", hero, hero)
    hero:AddItem(item)

    local item = CreateItem("item_destroy_all_farms", hero, hero)
    hero:AddItem(item)

    local item = CreateItem("item_build_aura_farm", hero, hero)
    hero:AddItem(item)
  elseif heroName == "npc_dota_hero_lycan" then
    InitAbilities(hero)
    hero:SetHullRadius(33) -- A hull radius of 32 will make pathing do weird things.
  end

  -- Remove Wearables
  if heroName == "npc_dota_hero_riki" or heroName == "npc_dota_hero_lycan" then
    print('Removing Wearables')
    hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
    hero.hiddenWearables = {} 
    local wearable = hero:FirstMoveChild()
    while wearable ~= nil do
     print(wearable:GetClassname())     
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
  --print("[SHEEPTAG] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      --print("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds
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
  end 

  if npc:GetUnitName() == "golem_datadriven" then
    npc:SetHullRadius(33)
    print('Golem Spawn')
  end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function SheepTag:OnEntityHurt(keys)
  ----print("[SHEEPTAG] Entity Hurt")
  ----PrintTable(keys)
  local entCause = EntIndexToHScript(keys.entindex_attacker)
  local entVictim = EntIndexToHScript(keys.entindex_killed)
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

  if killedUnit:IsRealHero() then
    --print ("KILLEDKILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if killedUnit:GetTeam() == DOTA_TEAM_BADGUYS and killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
      self.nRadiantKills = self.nRadiantKills + 1
      if END_GAME_ON_KILLS and self.nRadiantKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
      end
    elseif killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killerEntity:GetTeam() == DOTA_TEAM_BADGUYS then
      self.nDireKills = self.nDireKills + 1
      if END_GAME_ON_KILLS and self.nDireKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
      end
    end

    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireKills )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantKills )
    end
  end

  if killedUnit:GetUnitName() == "npc_dota_hero_riki" then
    --self:OnSheepKilled(killedUnit)
  end
  -- Put code here to handle when an entity gets killed
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
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
  --print('[SHEEPTAG] GameRules set')

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
  ListenToGameEvent('entity_hurt', Dynamic_Wrap(SheepTag, 'OnEntityHurt'), self)
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

  self.vPlayers = {}
  self.vRadiant = {}
  self.vDire = {}

  self.nRadiantKills = 0
  self.nDireKills = 0

  self.bSeenWaitForPlayers = false

  self.center = Entities:FindByName(nil, "spawn_center")

  --SendToServerConsole( "dota_wearables_clientside 1" )
  --SendToServerConsole( "dota_combine_models 0" )

  -- BH Snippet
  -- This can be called with an optional argument: nHalfMapLength (see readme)
  BuildingHelper:Init() --2688
  --BuildingHelper:BlockRectangularArea(Vector(-192,-192,0), Vector(192,192,0))

  Timers:CreateTimer(0, function()
      -- we have to handle the sheep animation
    for i,v in ipairs(HeroList:GetAllHeroes()) do
      if v and v:GetUnitName() == 'npc_dota_hero_riki' then
        if v:IsIdle() and v:HasModifier("modifier_sheep_run") then
          v:RemoveModifierByName("modifier_sheep_run")
        elseif not v:IsIdle() and not v:HasModifier("modifier_sheep_run") then
          GlobalDummy.sheepRun:ApplyDataDrivenModifier(GlobalDummy, v, "modifier_sheep_run", {})
        end
      end
    end
    return 0.01
  end)

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

    --mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

    --mode:SetFogOfWarDisabled( DISABLE_FOG_OF_WAR_ENTIRELY )
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )

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
  self.vUserIds[keys.userid] = ply

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
    self:OnSheepKilled(hero)
  end
  --[[
  if string.find(keys.text, "^-reset") and plyID == 0 then
    GameMode:ResetGame()
  end
  ]]
end

function SheepTag:OnSheepKilled( hero )
  local gold = hero:GetGold()
  local plyID = hero:GetPlayerID() 
  PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_wisp", 0, 0)
  local newHero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
  FindClearSpaceForUnit(newHero, Entities:FindByName(nil, "spawn_center"):GetAbsOrigin(), false)
  newHero:SetGold(gold, false)
end

function SheepTag:OnWispKilled( hero )
  local gold = hero:GetGold()
  local plyID = hero:GetPlayerID() 
  PlayerResource:ReplaceHeroWith(plyID, "npc_dota_hero_riki", 0, 0)
  local newHero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
  FindClearSpaceForUnit(newHero, Entities:FindByName(nil, "spawn_center"):GetAbsOrigin(), false)
  newHero:SetGold(gold, false)
end

function SheepTag:EndMessage()
  GameRules:SendCustomMessage("Thank you for playing Sheep Tag!", 0, 0)
  GameRules:SendCustomMessage("<font color='#7FFF00'>Remember to share your feedback on the Workshop Page</font>.", 0, 0)
  GameRules:SendCustomMessage("https://github.com/ynohtna92/SheepTag", 0, 0)
  GameRules:SendCustomMessage(" ", 0, 0)
end
