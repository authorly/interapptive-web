bkLib.onDomLoaded(function() {
	var myNicEditor = new nicEditor({iconsPath : '/assets/nicEditorIcons.gif', 
	                                 buttonList: ['fontFamily','fontSize','left','center', 'right', 'bold','italic','underline','strikeThrough', 'forecolor']});
	myNicEditor.setPanel('font-menu-buttons');
	myNicEditor.addInstance('text');
});