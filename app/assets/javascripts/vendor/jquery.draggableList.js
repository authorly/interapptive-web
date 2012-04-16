var tempOptions;

// plugin definition
$.fn.draggableList = function(options) {
	// Extend our default options with those provided.
	// Note that the first arg to extend is an empty object -
	// this is to keep from overriding our "defaults" object.
	var opts = $.extend({}, $.fn.draggableList.defaults, options);
	// Our plugin implementation code goes here.
	this.each(function() {
		var o = $.meta ? $.extend({}, opts, $this.data()) : opts;
		
		// FIXME
		tempOptions = o;
		
		CreateContainerDiv($(this), o);
	});
}

$.fn.adjustDraggableContainerDiv = function() {
	var newPanelHeight = $(this).height() * 2;
	newPanelHeight = newPanelHeight - tempOptions.height;

	// set its height and put it in the right place
	$(this).parent().css("height", newPanelHeight + "px");
	$(this).parent().css("position", "relative");
	var newPanelPosition = ($(this).height() - tempOptions.height) * -1
	$(this).parent().css("top", newPanelPosition);
	
	$(this).draggable({ axis: 'y', containment: 'parent' });
}

// plugin defaults - added as a property on our plugin function
$.fn.draggableList.defaults = {
	cursor: 'n-resize',
	height: '150',
	width: '100',
	listPosition: '0',
	panelCssClass:'draggableList'};

function CreateContainerDiv(dragTarget, options) {

	// add the panel to constrain the draggable section
	var newPanelHeight = dragTarget.height() * 2;
	newPanelHeight = newPanelHeight - options.height;
	dragTarget.wrap(document.createElement("div"));

	// set its height and put it in the right place
	dragTarget.parent().css("height", newPanelHeight + "px");
	dragTarget.parent().css("position", "relative");
	var newPanelPosition = (dragTarget.height() - options.height) * -1
	dragTarget.parent().css("top", newPanelPosition);

	// add the container panel
	dragTarget.parent().wrap(document.createElement("div"));
	dragTarget.parent().parent().css("cursor", options.cursor);
	dragTarget.parent().parent().css("height", options.height + "px");
	dragTarget.parent().parent().css("width", options.width + "px");
	dragTarget.parent().parent().css("overflow", "hidden");
	dragTarget.parent().parent().addClass(options.panelCssClass);

	// setup 'dragging' on the target...
	dragTarget.draggable({ axis: 'y', containment: 'parent' });
	
	// finally set the position of the list
	listPositionExplicit = newPanelPosition * ((100 - options.listPosition)/100)*-1
	dragTarget.css("top", listPositionExplicit + "px")

}