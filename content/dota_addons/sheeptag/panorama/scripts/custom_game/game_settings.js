"use strict"

function CheckForHostPrivileges(panel) {
	var playerInfo = Game.GetLocalPlayerInfo();
	$.Msg(playerInfo);
	if ( !playerInfo )
		return undefined;

	// Set the "player_has_host_privileges" class on the panel, this can be used 
	// to have some sub-panels on display or be enabled for the host player.
	$.GetContextPanel().SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );
	if (panel !== undefined) {
		panel.SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );
	}
	return playerInfo.player_has_host_privileges;
}

function SelectDefaultGameMode(panel) {
	panel.FindChildTraverse('game_mode').SetSelected('1');
	panel.FindChildTraverse('enabled_view').SetSelected(false);
	panel.FindChildTraverse('number_of_rounds').SetSelected('3');
	panel.FindChildTraverse('gold_start').SetSelected('0');
	panel.FindChildTraverse('round_time').SetSelected('10');
}

function DrawGameSettingsUI() {
	var isHost = CheckForHostPrivileges()
	//isHost = false;

	if (!isHost) {
		return;
	}

	var gameModePanel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
	gameModePanel.BLoadLayout( "file://{resources}/layout/custom_game/game_settings.xml", false, false );

	// default values
	SelectDefaultGameMode(gameModePanel);

	$.Msg("Drawing Settings UI!");
	
	// startup animation
	gameModePanel.style.x = '-250px';
	gameModePanel.style.opacity = 0;
	AnimatePanel(gameModePanel, { "transform": "translateX(250px);", "opacity": "1;" }, 1.0, "ease-out"); 
}

function SetGameSettings() {
	GameEvents.SendCustomGameEventToServer( "set_game_settings", {
		"isHost": CheckForHostPrivileges(),
		"modes": {
			"game": $.GetContextPanel().FindChildTraverse("game_mode").GetSelected().id,
			"enabled_view": $.GetContextPanel().FindChildTraverse("enabled_view").checked,
			"gold_start": $.GetContextPanel().FindChildTraverse("gold_start").GetSelected().id,
			"round_time": $.GetContextPanel().FindChildTraverse("round_time").GetSelected().id,
			"number_of_rounds": $.GetContextPanel().FindChildTraverse("number_of_rounds").GetSelected().id,
		}
	});
}

(function () {
	$.Msg( "Game Settings Panel Loaded!" );
})();