describe "App.Models.ButtonWidget", ->

  describe 'initialization', ->
    beforeEach ->
      @imageId = 13
      image = new Backbone.Model(id: @imageId, name: 'image.png', url: 'image.url')
      @collection = {scene: { storybook: {images: new Backbone.Collection(image)}}}

    it 'has the right defaults', ->
      @widget = new App.Models.ButtonWidget
      expect(@widget.get('type')).toEqual 'ButtonWidget'

    describe 'filename', ->
      it 'gets the filename based on the name, if image is not present', ->
        @widget = new App.Models.ButtonWidget({name: 'kind'}, collection: @collection)
        expect(@widget.filename()).toEqual 'kind.png'

      it 'gets the filename from the image, if provided', ->
        @widget = new App.Models.ButtonWidget({image_id: 13}, collection: @collection)
        expect(@widget.filename()).toEqual 'image.png'

    describe 'url', ->
      it 'gets the url based on the name, if image is not present', ->
        @widget = new App.Models.ButtonWidget({name: 'kind'}, collection: @collection)
        expect(@widget.url()).toEqual '/assets/sprites/kind.png'

      it 'gets the url based on the image, if provided', ->
        @widget = new App.Models.ButtonWidget({image_id: 13}, collection: @collection)
        expect(@widget.url()).toEqual 'image.url'
