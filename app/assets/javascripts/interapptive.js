// Text editor setup/initialization
bkLib.onDomLoaded(function() {
	// Initialize text editor
	var myNicEditor = new nicEditor({iconsPath : '/assets/nicEditorIcons.gif', 
	                                 buttonList: ['fontFamily','fontSize','left','center', 'right', 'bold','italic','underline','strikeThrough', 'forecolor']});
	// Font formatting toolbar
	myNicEditor.setPanel('font-menu-buttons');
	
	// Make instance out of element (param is ID of element)
	myNicEditor.addInstance('text');

	// Appropriate toolbar background upon focusing on text editor
	myNicEditor.addEvent('focus', function() {
    $('ul#toolbar li ul li').removeClass('active');
		$('ul#toolbar li ul li.edit-text').addClass('active');
  });

	// Remove active state from toolbar when losing focus on text editor
	myNicEditor.addEvent('blur', function() {
    $('ul#toolbar li ul li.edit-text').removeClass('active');
  });
});

$(function() {
	// Toolbar items (big icons)
	var toolbar_item = $('ul#toolbar li ul li');
	// Selector for all of our modals
	var modals = $('#myModal');
	
	// Modal & modal related
	// init modals
	modals.modal({backdrop: true}).modal('hide');
	
	// remove active state from toolbar
	modals.bind('hidden', function () {
	  // remove active state from toolbar
	 toolbar_item.removeClass('active');
	});
	
	// Initialize drop down menu (for file/top-most menu)
	$('.dropdown-toggle').dropdown()
	
	// Active states appropriation for sidebar
	$('.keyframe-list').on('click', 'li', function(e) {
		$('.keyframe-list li').removeClass('active');
		$(this).addClass('active');
	});
	$('.scene-list').on('click', 'li', function(e) {
		$('.scene-list li').removeClass('active');
		$(this).addClass('active');
	});
	
	// Draggable lists for keyframes + scenes on sidebar
	$('.keyframe-list, .scene-list').draggableList({height:500, width:170, listPosition:0});
	
	// Toggle active state for toolbar on menu clicks
	toolbar_item.click(function() {
		// close any modals that are open
		modals.modal('hide');
		
		// Check if user clicked specific buttons (by CSS classes, maybe use their own attribute for clarity)
		if ($(this).hasClass("edit-text")) { 
				// Should focus on text editor here FIXME
		// Append new elements for new scenes/keyframes 
		// & adjust styles accordingly for showing tabs
		} else if ($(this).hasClass("scene") || $(this).hasClass("keyframe")) {

			$('.nav-tabs li, .tab-pane ul li, .tab-pane').removeClass('active');
			
			if ($(this).hasClass("keyframe")) {
				
				// change border + write HTML to document for new keyframe
				$('#keyframe-list, .nav-tabs li.keyframe-tab').addClass('active');
				$('<li class="active"><span></span></li>').prependTo($('#keyframe-list ul'));
				
				// Set the draggable list container to account for new element
				$('.keyframe-list').adjustDraggableContainerDiv();
				
			} else if ($(this).hasClass("scene")) {
				
				// change border + write HTML to document for new scene
				$('#scene-list, .nav-tabs li.scene-tab').addClass('active');
				$('<li class="active"><span></span></li>').prependTo($('#scene-list ul'));
				
				// Set the draggable list container to account for new element
				$('.scene-list').adjustDraggableContainerDiv();
			}
			
			// return early to avoid state change of menu background (since adding a new scene or keyframe)
			return;
		} else if($(this).hasClass("videos") || 
							$(this).hasClass("fonts") || 
							$(this).hasClass("actions") || 
							$(this).hasClass("images") || 
							$(this).hasClass("sounds") || 
							$(this).hasClass("add-image") ||
							$(this).hasClass("preview") ||
							$(this).hasClass("touch-zones")) {
			// Show modal for videos
			$('#myModal').modal('show');
		}	
		
		// Proper toggle effect for menu items
		$("ul#toolbar li ul li").not(this).removeClass("active");
		$(this).toggleClass("active");
	});
});