--[[
		**Documentation**

	***(NOTE THE CASE SENSITIVITY USAGE)***
	
	You need to go to layout/customuimanifest.xml and include this:
		--<CustomUIElement type="Hud" layoutfile="file://{resources}/layout/custom_game/ScoreBoard.xml" />
	Which loads in the xml and scrips/styles attached to that

	you also need to require this file in the addon_game or gamemode script file in order to be able to use it. 
		--require('scoreboard')

	**Styling tables**
	I would highly recommend using styling tables, they're bassically lua tables that hold all the styles you want for your scoreboard, these are some samples for what we use down below:

	styles for the first team, name is irrelevant
		--Team1Header=	{height="100%", width="85px", color="white",  ["border-radius"]="5px"}
		--Team1Content=	{height="100%", width="85px", color="black",   ["background-color"]="white",  ["border-radius"]="5px"}
			
	style for a random member that I can make stand out
		--Team1Part2=	{height="100%", width="85px", color="red",   ["background-color"]="yellow",  ["border-radius"]="5px"}
			
	styles for the second team, name is irrelevant.
	   --Team2Header=	{height="100%", width="85px", color="orange", ["border-radius"]="5px"}
	   --Team2Content ={height="100%", width="85px", color="black", ["background-color"]="orange",  ["border-radius"]="5px"}

	**Creating the Headers & Container**
	**DO THIS FIRST ALWAYS**
	This creates the main containers and is the setup call where you specify the headers in sequence and also whether you want a header text using false = hide 
		--ScoreBoard:Setup({header={"The Wackies", "The Mighties"},x="10px", headertext={true, true}, headerstyle={Team1Header, Team2Header}})
		
	**Creating the Columns**
	**THIS SHOULD BE CALLED BEFORE CREATING PLAYERS**
	This is how to create columns for the scoreboard, you have to specify a style, the name of the column and which header it goes under
	   ScoreBoard:CreateColumnHeader({name="Name",     header="The Wackies", visible=true, style=Team1Content})
	   ScoreBoard:CreateColumnHeader({name="Level",	header="The Wackies", visible=true, style=Team1Content})
	   ScoreBoard:CreateColumnHeader({name="Gold",     header="The Wackies", visible=true, style=Team1Part2})
	   ScoreBoard:CreateColumnHeader({name="Lumber",   header="The Wackies", visible=true, style=Team1Content})
	   ScoreBoard:CreateColumnHeader({name="Deaths",   header="The Wackies", visible=true, style=Team1Content})
	   ScoreBoard:CreateColumnHeader({name="Revives",  header="The Wackies", visible=true, style=Team1Content})		
	   
	   ScoreBoard:CreateColumnHeader({name="Name", 	header="The Mighties", visible=true, style=Team2Content})
	   ScoreBoard:CreateColumnHeader({name="Level",    header="The Mighties", visible=true, style=Team2Content})
	   ScoreBoard:CreateColumnHeader({name="Gold",     header="The Mighties", visible=true, style=Team2Content})
	   ScoreBoard:CreateColumnHeader({name="Lumber",   header="The Mighties", visible=true, style=Team2Content})
	   ScoreBoard:CreateColumnHeader({name="Deaths",   header="The Mighties", visible=true, style=Team2Content})
	   ScoreBoard:CreateColumnHeader({name="Revives",  header="The Mighties", visible=true, style=Team2Content})

	**Creating the players**
	Creating players requires playerid input and the header you want to create them under(OPTIONALLY A STYLE)
	  --ScoreBoard:CreatePlayer({playerID=playerID, header="The Mighties"})	
	  --ScoreBoard:CreatePlayer({playerID=playerID, header="The Wackies", style=Team4})	
	  --ScoreBoard:CreatePlayer({playerID=playerID, header="The Wackies"})
	  
	**Updating**

	Two ways to update scoreboard:
	Here you can update a single player you should use this in a loop from 0 to PlayerResource:GetPlayerCount() -1(NOTE: KEY="PLAYER" to update single player)
		--ScoreBoard:Update( {key="PLAYER", ID=playerID, panel={ "Name", "Level", "Gold", "Lumber", "Deaths", "Revives"}, paneltext={"Infekma", 1, 9001, 9001, 0, 9001}})

	You can also update using table's, make sure your values inside your table match the panel order(NOTE: KEY="ALL" to use this)
		--ScoreBoard:Update( {key="ALL", panel={ "Name", "Level", "Gold", "Lumber", "Deaths", "Revives"}, paneltext=PlayerTable})

	**Functionality**
	duration can be used to Delete scoreboard, or players after the duration time specified
	  --ScoreBoard:CreatePlayer({playerID=playerID, header="The Wackies", duration=60})
	NOTE: This will delete the player after 1minute, if duration is left unspecified it is permanent    

		ScoreBoard:Setup({header={"The Wackies", "The Mighties"},x="10px", headertext={true, true}, headerstyle={Team1Header, Team2Header}, duration=60}) 
	NOTE: This will delete the entire scoreboard after 60seconds, if duration is left unspecified it is permanent

	**EDiting Specific Components(wip kinda)**
	This command hides the section header(can include stylesheets to)
	   --ScoreBoard:Edit({key="COLUMN_HEADER", header="The Mighties", visible = false})
			
	This command hides the visibility(can include stylesheets to)
	   --ScoreBoard:Edit({key="CONTAINER", visible = false})		
			
	This command styles the main container as seen before
	   --ScoreBoard:Edit({key="CONTAINER", style={["margin-left"]="250px", ["background-color"]="grey"}})
	   

		Huge thanks to BMD, this was made/inspired using his notifications library as a reference
--]]

	--Sample ScoreBoard
--[[

	-- Styling tables (where we keep all our styles for each component)
	Team1Header=		{height="100%", width="85px", color="white",  ["border-radius"]="5px"}
	Team1Content=		{height="100%", width="85px", color="black",   ["background-color"]="white",  ["border-radius"]="5px"}
	
	Team1Part2=	{height="100%", width="85px", color="red",   ["background-color"]="yellow",  ["border-radius"]="5px"}
	
	Team2Header=		{height="100%", width="85px", color="orange", ["border-radius"]="5px"}
	Team2Content =		{height="100%", width="85px", color="black", ["background-color"]="orange",  ["border-radius"]="5px"}

 	-- setting up the primary container and headers
	ScoreBoard:Setup({header={"The Wackies", "The Mighties"},x="10px", headertext={true, true}, headerstyle={Team1Header, Team2Header}})
	ScoreBoard:Edit({key="CONTAINER", style={["background-color"]="#242424", border="2px solid grey"}})
		
	-- setting up the columnheaders for each section
	--ScoreBoard:CreateColumnHeader({name="Name",     header="The Wackies", visible=true, style=Team1Content})
	--ScoreBoard:CreateColumnHeader({name="Level",	header="The Wackies", visible=true, style=Team1Content})
	--ScoreBoard:CreateColumnHeader({name="Gold",     header="The Wackies", visible=true, style=Team1Part2})
	--ScoreBoard:CreateColumnHeader({name="Lumber",   header="The Wackies", visible=true, style=Team1Content})
	--ScoreBoard:CreateColumnHeader({name="Deaths",   header="The Wackies", visible=true, style=Team1Content})
	--ScoreBoard:CreateColumnHeader({name="Revives",  header="The Wackies", visible=true, style=Team1Content})
		
	-- Setting up the team mighties section(the last line of this section hides columnheaders so that you only need to use the one from the previous team)
		--ScoreBoard:CreateColumnHeader({name="Name", 	header="The Mighties", visible=true, style=Team2Content})
		--ScoreBoard:CreateColumnHeader({name="Level",    header="The Mighties", visible=true, style=Team2Content})
		--ScoreBoard:CreateColumnHeader({name="Gold",     header="The Mighties", visible=true, style=Team2Content})
		--ScoreBoard:CreateColumnHeader({name="Lumber",   header="The Mighties", visible=true, style=Team2Content})
		--ScoreBoard:CreateColumnHeader({name="Deaths",   header="The Mighties", visible=true, style=Team2Content})
		--ScoreBoard:CreateColumnHeader({name="Revives",  header="The Mighties", visible=true, style=Team2Content})
		--ScoreBoard:Edit({key="COLUMN_HEADER", header="The Mighties", visible = false})

	-- style table to make a specific components stand out or player
		--Team4={color="red",   ["background-color"]="black",  ["border-radius"]="5px"}
	
	-- creating players on team mighties, (NOTE: if you don't specify a style it will inherit from the header)
		--ScoreBoard:CreatePlayer({playerID=3, header="The Mighties"})
		--ScoreBoard:CreatePlayer({playerID=2, header="The Mighties"})
		--ScoreBoard:CreatePlayer({playerID=1, header="The Mighties", style=Team4})
	
	-- creating players on team wackies
		--ScoreBoard:CreatePlayer({playerID=0, header="The Wackies"})
		
	-- these are optional but just samples of what you can also do after having initialised all the previous, you can hide headertexts or add additional styling
		--ScoreBoard:Edit({key="COLUMN_HEADER", header="The Mighties", visible = false})
		--ScoreBoard:Edit({key="CONTAINER", visible = false})
	
		--ScoreBoard:Edit({key="CONTAINER", style={["margin-left"]="250px", ["background-color"]="grey"}})
--]]

if ScoreBoard == nil then
	ScoreBoard = class({})
	print("[ScoreBoard] Setup Completed")
end

local Panels = Panels or {} local PanelText = PanelText or {}

function ScoreBoard:Setup(table)
	CustomGameEventManager:Send_ServerToAllClients( "scoreboard_setup", {header = table.header, headerstate = table.headertext, duration = table.duration, headerstyle = table.headerstyle, x=table.x})
end

local CurrentPanelIndex = 0
function ScoreBoard:CreateColumnHeader(table)
	-- store table to Panel for reference for column content creation(player creation)
	Panels[CurrentPanelIndex] = table
	CurrentPanelIndex = CurrentPanelIndex + 1
	
	CustomGameEventManager:Send_ServerToAllClients("scoreboard_setup_header", {style = table.style, name = table.name, header = table.header, visible = table.visible})	
end

function ScoreBoard:Update(table)
	if table.key == "PLAYER" and not (table.ID >= 0 and table.ID <= PlayerResource:GetPlayerCount()-1) then
		print("[SCOREBOARD] Incorrect PlayerID or Meant to use key=ALL")
		return
	elseif Panels == nil then
		print("[SCOREBOARD] Cannot update due to non-existent panel table, implying you have not called CreateColumns yet")
		return
	elseif table.key == "ALL" and table.ID ~= nil then
		print("[SCOREBOARD] No need to define ID if key=ALL or meant to use key=PLAYER, continuing regardless")
	end
		
	if table.key == "ALL" then
		for i = 0, PlayerResource:GetPlayerCount() - 1, 1 do
		local CurrentPanelText = table.PanelText[i]
			CustomGameEventManager:Send_ServerToAllClients( "scoreboard_update_all", {PlayerID=i, Panel= table.panel, PanelText=CurrentPanelText})
		end
	elseif table.key == "PLAYER" then
		CustomGameEventManager:Send_ServerToAllClients( "scoreboard_update_all", {PlayerID=table.ID, Panel=table.panel, PanelText=table.paneltext})
	end
end

function ScoreBoard:CreatePlayer(table)
	if not (table.playerID >= 0 and table.playerID <= PlayerResource:GetPlayerCount()-1) then
		print("[SCOREBOARD] Incorrect PlayerID given in CreatePlayer")
		return
	elseif table.header == nil then
		print("[SCOREBOARD] Did not specify under which HEADER to create Player #"..table.playerID)
		return
	elseif Panels == nil then
		print("[SCOREBOARD] Cannot create player before creating columns")
		return
	end
	
	CustomGameEventManager:Send_ServerToAllClients("scoreboard_create_players", { PlayerID = table.playerID, panel = Panels, header = table.header, style=table.style, duration = table.duration})	
end

function ScoreBoard:Edit(table)

	if table.key == nil then
		print("[SCOREBOARD] key not specified, unable to determine what action to take")
	end

	CustomGameEventManager:Send_ServerToAllClients("scoreboard_stylize", {key = table.key, header = table.header, style=table.style, visible = table.visible})	
end