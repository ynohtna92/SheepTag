
var rootparentORG = $('#HUDContainer')
var rootparent = null
var Section = null

function Setup_ScoreBoard( data ){
	$.Msg("Setup Scoreboard")	 
    
	// create primary container used for deletion process/house all
	rootparent = $.CreatePanel ('Panel', rootparentORG, 'Primary_Container')
	rootparent.AddClass('Primary_Container') 
	rootparent.hittest = false
	 
	if (data.x != null){ 
		//$.Msg("margin left")
		rootparent.style['margin-left'] = data.x
	}
	
	// create all headers
	for (var key in data.header){
		$.Msg("Setting up header #" +key) 
		Setup_HeadersAndSection(data.header[key], data.headerstate[key], data.headerstyle[key])
	}
	
	// set container to delete with specified time
	if(data.duration != null){  
		rootparent.DeleteAsync(data.duration) 
	} 
}

function Setup_HeadersAndSection ( name, headerstate, style ){ 
	// Create Header & Column Container
	
	//if headerstate is true then create the text 
	if(headerstate == true){
		var HeaderLabel = $.CreatePanel('Label', rootparent, 'Label_'+name)
		HeaderLabel.text = name
		HeaderLabel.AddClass('SectionHeaderText')
		HeaderLabel.hittest = false
		
		if(style != null){ 
			if(style["background-color"] != null){
				$.Msg("background color") 
				HeaderLabel.style["background-color"]=style["background-color"]
			} 
			if(style["color"] != null){
				HeaderLabel.style["color"]=style["color"]
			} 
			if(style["border"] != null){
				HeaderLabel.style["border"]=style["border"]
			}      
		}         
	}
	
	var SectionContainer = $.CreatePanel ('Panel', rootparent, 'Section_'+name)
	SectionContainer.AddClass('SectionContainer')
	SectionContainer.hittest = false
	
	// Create Column Header 
	var SectionHeader = $.CreatePanel ('Panel', SectionContainer, 'Section_Header_'+name)
	SectionHeader.AddClass('SectionHeader')
	SectionHeader.hittest = false
	SectionHeader.visible = false
	
	// Create Column Content Container
	Section = $.CreatePanel ('Panel', SectionContainer, 'Section_Container_'+name)
	Section.AddClass('Section')  
	Section.hittest = false
} 
 
function Create_Column_Header (data){
	$.Msg("Creating Column Headers")	
	 
	var Header = $.FindChildInContext('#Section_Header_'+data.header, '#HUDContainer')
	Header.hittest = false
	
	var ColumnHeader = $.CreatePanel('Panel', Header, '')
	ColumnHeader.hittest = false
	 
	var ColumnHeaderLabel = $.CreatePanel('Label', ColumnHeader, '')
	ColumnHeaderLabel.text = data.name
	ColumnHeaderLabel.AddClass('HeaderText')
	ColumnHeaderLabel.hittest = false
	 
	if (data.visible == false){
		ColumnHeader.visible = false 
	}
	
	// style column header
	if (data.style != null){  
		stylize(data.style, ColumnHeader)
	} 
	else{
		ColumnHeader.AddClass("PlayerStats")
	}
}
 
function Create_Column_Content( playerID, parent, name, style){ 
	
	var ColumnContainer = $.CreatePanel('Panel', parent, 'Section_Container_'+name)
	ColumnContainer.hittest = false
	
	var ColumnContent = $.CreatePanel('Label', ColumnContainer, name+"_"+playerID)
	ColumnContent.text = "--"  
	ColumnContent.AddClass('PlayerText') 
	ColumnContent.hittest = false
	   
	// create column styling
	if (style != null){  
		stylize(style, ColumnContainer) 
	} 
	else{  
		ColumnContainer.AddClass("PlayerStats")
	}    

}     

 function stylize(style, panel){
	for (var key in style) {     
		var value = style[key]
		panel.style[key] = value; 
	}     	  
 }  
 
function Create_Player_ScoreBoard ( data ){
	$.Msg("Create Player Scoreboard") 	 

	// player details
	var playerID = data.PlayerID
	
	// Parent of which to create the playerID Section under
	var parent = $.FindChildInContext('#Section_Container_'+data.header, '#Section_'+data.header)
	
	if($.FindChildInContext('#'+playerID, '#Section_'+data.header) == null){
		// Create player section
		$.Msg("Creating Player #" + playerID)	
		var PlayerSection = $.CreatePanel ('Panel', parent, playerID)
		PlayerSection.AddClass('PlayerSection')
		PlayerSection.hittest = false
		
	} else{return;}
	
	if(data.duration != null){  
		PlayerSection.DeleteAsync(data.duration)
	}
	
	// change parent to playerID Section
	parent = $.FindChildInContext('#' +playerID, '#HUDContainer')
	
	var count = $('#Section_Header_'+data.header).GetChildCount()
	var panelCreated = 0   
	// make panel visible
	$('#Section_Header_'+data.header).visible = true
	
	// Create Column Content
	for (var key in data.panel){
	//$.Msg(data.Panel) 
   
		if(data.panel[key].header == data.header && panelCreated+1<= count) 
		{	 
			panelCreated = panelCreated+1  
			//$.Msg("creating panel")     

			var style = data.panel[key].style 
			if(data.style != null){  
				for (var innerkey in data.style){
					data.panel[key].style[innerkey] = data.style[innerkey]
				}   
			}
			var name = data.panel[key].name
			Create_Column_Content( playerID, parent, name, style) 			
		}   
	} 
	//CreateButton(parent, playerID)   
} 
 


function CreateButton(parent, playerID){
	var TPButton = $.CreatePanel('Button', parent, 'PlayerButton')
	TPButton.AddClass('TPButton')
	
	var TPButtonLabel = $.CreatePanel('Label', TPButton, 'PlayerButtonLabel')
	TPButtonLabel.text = "Join"
	TPButtonLabel.AddClass('TPButtonText')

	TPButton.SetPanelEvent("onactivate", mouseClick(playerID))
}

// button click example that I use myself
var mouseClick = (
	function(id)  
	{ 
		return function() 
		{
			GameEvents.SendCustomGameEventToServer( "player_tp", { "TeleportTo" : id} );
		}
	});
 
function UpdateAll(data){ 
var playerID = data.PlayerID

	for (var key in data.Panel) {
		//$.Msg(data.Panel[key])
		var Panel = '#'+data.Panel[key]+"_"+playerID
		var PanelText = null

		// check paneltext exist and isn't null
		if (data.PanelText[key] == null){
			data.PanelText[key] = "Nill"
			$.Msg("[SCOREBOARD] " +Panel[key]+" was not provided with text")
		} 
		else{
			PanelText = data.PanelText[key]
		}
		
		// check the given panel exist and isn't null
		if($.FindChildInContext(Panel, playerID) == null){
			$.Msg("[SCOREBOARD] Panel given does not exist")			
		}
		else{
			$.FindChildInContext(Panel, "#Primary_Container").text = PanelText
		}		 
	} 

	// Usage: $.FindChildInContext(FindThis, InThis)
}      
  
function StylizePanel(data){ 
var PanelToEdit = null  

	if(data.key == "COLUMN_HEADER"){ 
		PanelToEdit = $.FindChildInContext("#Section_Header_"+data.header,'Section_'+data.header )
	} 
	else if(data.key == "CONTAINER"){
		PanelToEdit = $.FindChildInContext('#Primary_Container', rootparentORG )
	}      
		
	
	if(data.visible != null){ 
		PanelToEdit.visible = data.visible
	}    	  
	if(data.style != null){ 
		stylize(data.style, PanelToEdit)
	}   
		
} 

// Button that collapse/expands the scoreboard
function HideShowPlayerScoreboard(){
	if ($("#HUDContainer").visible)
	{
		$("#HUDContainer").visible = false
	}  
	else
	{		
		$("#HUDContainer").visible = true
	}
}

// This will delete the entire scoreboard
function DeleteScoreboard(){
	rootparent.DeleteAsync(0);
}

(function () {
	GameEvents.Subscribe( "scoreboard_create_players", Create_Player_ScoreBoard );
	
	GameEvents.Subscribe( "scoreboard_setup", Setup_ScoreBoard );
	
	GameEvents.Subscribe( "scoreboard_setup_header", Create_Column_Header );
	GameEvents.Subscribe( "scoreboard_setup_content", Create_Column_Content );
	
	GameEvents.Subscribe( "scoreboard_stylize", StylizePanel );
	GameEvents.Subscribe( "scoreboard_update_all", UpdateAll );

	GameEvents.Subscribe( "scoreboard_delete", DeleteScoreboard );
})();

/*
	Created By: Infekma
	<------------------------------------------->
				Scoreboard Hierachy:
	<------------------------------------------->
	-- Root
		-- Container
			-- HeaderLabel
			-- Header
				-- HeaderSection
					-- Column Headers
			-- Content	
				-- PlayerSection
					-- Column Content
	<------------------------------------------->
*/
