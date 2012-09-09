class App.Views.AssetLibrary extends Backbone.View
  template: JST["app/templates/assets/library"]

  render: ->
    $(@el).html(@template(assetType: @activeAssetType))
    this

  initAssetLibFor: (type) ->
    @assetType = type.replace(/(\s+)?.$/, "") # Remove last char. from params (an "s")
    $(".content-modal").addClass "asset-library-modal"
    $("#fileupload").fileupload
      downloadTemplateId: null
      uploadTemplateId: null
      downloadTemplate: JST["app/templates/assets/" + @assetType + "s/download"]
      uploadTemplate: JST["app/templates/assets/" + @assetType + "s/upload"]
    @loadAndShowFileData()

  loadAndShowFileData: ->
    $.getJSON "/storybooks/#{App.currentStorybook().get('id')}/" + @assetType + "s", (files) ->
      fileData = $("#fileupload").data("fileupload")
      fileData._adjustMaxNumberOfFiles -files.length
      template = fileData._renderDownload(files).prependTo($("#fileupload .files"))
      fileData._reflow = fileData._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()
      $("#searchtable").show();
      $(".table-striped").advancedtable({searchField: "#search", loadElement: "#loader", searchCaseSensitive: false, ascImage: "/assets/advancedtable/up.png", descImage: "/assets/advancedtable/down.png"});
      
      

  closeAssetLib: ->
    $("#fileupload").fileupload "disable"
    $('.content-modal').removeClass "asset-library-modal"

  setAllowedFilesFor: (assetType) ->
    switch assetType
      when "images" then $("#fileupload").fileupload(acceptFileTypes: /\.(jpg|jpeg|gif|png|JPG|JPEG|GIF|PNG)$/)
      when "videos" then $("#fileupload").fileupload(acceptFileTypes: /\.(mov|mpg|mpeg|mkv|mp4|m4v|avi|flv|MOV|MPEG|MPEG|MP4|M4V|AVI|FLV)$/)
      when "fonts"  then $("#fileupload").fileupload(acceptFileTypes: /\.(ttf|TTF)$/)
      when "sounds" then $("#fileupload").fileupload(acceptFileTypes: /\.(mp3|wav|aac|m4a|MP3|WAV|AAC|M4A)$/)
