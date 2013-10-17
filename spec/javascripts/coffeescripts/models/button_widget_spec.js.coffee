describe "App.Models.ButtonWidget", ->

  describe 'initialization', ->

    it 'has the right defaults', ->
      @widget = new App.Models.ButtonWidget
      expect(@widget.get('type')).toEqual 'ButtonWidget'

  describe 'derived fields', ->
    beforeEach ->
      @imageId = 13
      image = new Backbone.Model(id: @imageId, name: 'image.png', url: 'image.url')
      @collection = {storybook: {images: new Backbone.Collection(image)}}

    describe 'filename', ->
      it 'gets the filename based on the name, if image is not present', ->
        @widget = new App.Models.ButtonWidget({name: 'kind'}, collection: @collection)
        expect(@widget.filename()).toEqual 'kind.png'

      it 'gets the filename from the image, if provided', ->
        @widget = new App.Models.ButtonWidget({image_id: @imageId}, collection: @collection)
        expect(@widget.filename()).toEqual 'image.png'

    describe 'url', ->
      it 'gets the url based on the name, if image is not present', ->
        @widget = new App.Models.ButtonWidget({name: 'kind'}, collection: @collection)
        expect(@widget.url()).toEqual '/assets/sprites/kind.png'

      it 'gets the url based on the image, if provided', ->
        @widget = new App.Models.ButtonWidget({image_id: @imageId}, collection: @collection)
        expect(@widget.url()).toEqual 'image.url'


    describe 'display name', ->
      it 'is "Home button" for home ', ->
        @widget = new App.Models.ButtonWidget({name: 'home'}, collection: @collection)
        expect(@widget.displayName()).toEqual 'Home button'

      it 'is the humanized name for others', ->
        @widget = new App.Models.ButtonWidget({name: 'a_name'}, collection: @collection)
        expect(@widget.displayName()).toEqual 'A name'


  describe 'disabled', ->
    it "cannot be disabled if it's read it myself", ->
      @widget = new App.Models.ButtonWidget(name: 'read_it_myself')
      expect(@widget.canBeDisabled()).not.toBeTruthy()

    it "can be disabled if it's read to me", ->
      @widget = new App.Models.ButtonWidget(name: 'read_to_me')
      expect(@widget.canBeDisabled()).toBeTruthy()

    it "can be disabled if it's autoplay", ->
      @widget = new App.Models.ButtonWidget(name: 'auto_play')
      expect(@widget.canBeDisabled()).toBeTruthy()
