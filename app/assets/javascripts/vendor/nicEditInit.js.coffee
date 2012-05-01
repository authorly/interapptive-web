# Text editor setup/initialization
bkLib.onDomLoaded ->
  # Initialize text editor
  myNicEditor = new nicEditor
    iconsPath: "/assets/nicEditorIcons.gif"
    buttonList: [ "fontFamily", "fontSize", "left", "center", "right", "bold", "italic", "underline", "strikeThrough", "forecolor" ]
  
  # Font formatting toolbar
  myNicEditor.setPanel "font-menu-buttons"

  # Make instance out of element (param is ID of element)
  myNicEditor.addInstance "text"

  # Appropriate toolbar background upon focusing on text editor
  myNicEditor.addEvent "focus", ->
    $("ul#toolbar li ul li").removeClass "active"
    $("ul#toolbar li ul li.edit-text").addClass "active"

  # Remove active state from toolbar when losing focus on text editor
  myNicEditor.addEvent "blur", ->
    $("ul#toolbar li ul li.edit-text").removeClass "active"