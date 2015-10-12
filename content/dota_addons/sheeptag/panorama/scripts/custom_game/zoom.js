// Mouse wheel things
var	ZOOM_RATE = 100;
var MAX_ZOOM = 150; // 2400 | 2700 | 3350
var MIN_ZOOM = -1850; // 1350
var CONSUME_EVENT = true;
var CONTINUE_PROCESSING_EVENT = false;

// Other things
var TEXT_CONVERSION = 3200;
var ZOOM_INTERVAL = 0.03;
var ZOOM_JUMP = 10;
var FAST_ZOOM = 10;
var DEFAULT_ZOOM = 0;

/**
 * Call this to set the zoom. Eventually, if they ever add
 * camera moving functionality from panorama, I'll make it move
 * the camera up and down so the zoom zooms in and out of the
 * what you're currently viewing instead of just vertically.
 */
function SetZoom( newZoom ) {
	GameUI.SetCameraLookAtPositionHeightOffset(newZoom);
	currZoom = newZoom;
	
	//var zoomPanel = $( "#CurrZoom" )
	//zoomPanel.text = bufferedZoom + TEXT_CONVERSION;
}

var currZoom = DEFAULT_ZOOM;
var bufferedZoom = DEFAULT_ZOOM;
var locked = false;
SetZoom(DEFAULT_ZOOM);

function AdjustZoom() {
	var newZoom = currZoom;
	if (bufferedZoom > newZoom) {
		var diff = bufferedZoom - newZoom;
		if (diff < ZOOM_JUMP)
			newZoom = bufferedZoom;
		else if (diff / 10 < ZOOM_JUMP)
			newZoom += ZOOM_JUMP;
		else
			newZoom += diff / 10;
	} else if (bufferedZoom < currZoom) {
		var diff = currZoom - bufferedZoom;
		if (diff < ZOOM_JUMP)
			newZoom = bufferedZoom;
		else if (diff / 10 < ZOOM_JUMP)
			newZoom -= ZOOM_JUMP;
		else
			newZoom -= diff / 10;
	}
	
	SetZoom( newZoom );
	
	if (bufferedZoom != currZoom)
		$.Schedule(ZOOM_INTERVAL, function(){AdjustZoom();});
}

function UpdateZoom( msg ) {
	bufferedZoom = msg.zoom - 2200;
	AdjustZoom();
}

(function () {
  GameEvents.Subscribe( "adjust_zoom", UpdateZoom );
})();