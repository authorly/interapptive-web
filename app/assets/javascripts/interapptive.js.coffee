window.App =
  Models: {}
  Views: {}
  Collections: {}

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

$ ->
  # Toolbar items
  toolbarItem = $("ul#toolbar li ul li")

  # Selector for all of our modals
  modals = $("#myModal")

  # Init modals
  modals.modal(backdrop: true).modal "hide"

  modals.bind "hidden", ->
    toolbarItem.removeClass "active"

  $(".dropdown-toggle").dropdown()

  $(".keyframe-list").on "click", "li", (e) ->
    $(".keyframe-list li").removeClass "active"
    $(this).addClass "active"

  $(".scene-list").on "click", "li", (e) ->
    $(".scene-list li").removeClass "active"
    $(this).addClass "active"

  $(".keyframe-list, .scene-list").draggableList
    height: 500
    width: 170
    listPosition: 0

  toolbarItem.click ->
    modals.modal "hide"
    if $(this).hasClass("edit-text")

    else if $(this).hasClass("scene") or $(this).hasClass("keyframe")
      $(".nav-tabs li, .tab-pane ul li, .tab-pane").removeClass "active"

      if $(this).hasClass("keyframe")
        $("#keyframe-list, .nav-tabs li.keyframe-tab").addClass "active"
        $("<li class=\"active\"><span></span></li>").prependTo $("#keyframe-list ul")
        $(".keyframe-list").adjustDraggableContainerDiv()
      else if $(this).hasClass("scene")
        $("#scene-list, .nav-tabs li.scene-tab").addClass "active"
        $("<li class=\"active\"><span></span></li>").prependTo $("#scene-list ul")
        $(".scene-list").adjustDraggableContainerDiv()
      return
    else $("#myModal").modal "show" if $(this).hasClass("videos") or
                                       $(this).hasClass("fonts") or
                                       $(this).hasClass("actions") or
                                       $(this).hasClass("images") or
                                       $(this).hasClass("sounds") or
                                       $(this).hasClass("add-image") or
                                       $(this).hasClass("preview") or
                                       $(this).hasClass("touch-zones")
    $("ul#toolbar li ul li").not(this).removeClass "active"
    $(this).toggleClass "active"
