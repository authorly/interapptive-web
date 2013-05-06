describe "App.Views.Storybooks.SettingsForm", ->

  describe "attribute validation", ->
    beforeEach ->
      view = new App.Views.Storybooks.SettingsForm
        model: new App.Models.Storybook
      @errors = view.form.commit()

    it "should require a title", ->
      expect(@errors.title.message).toEqual "Required"

    it "should require a price", ->
      expect(@errors.price.message).toEqual "Required"

    it "should require a description", ->
      expect(@errors.description.message).toEqual "Required"

    it "should require a author", ->
      expect(@errors.author.message).toEqual "Required"
