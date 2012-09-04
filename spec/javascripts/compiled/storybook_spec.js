(function() {

  describe("App.Views.Storybook", function() {
    beforeEach(function() {
      this.storybook = new App.Models.Storybook({
        title: "Wake up",
        id: 7
      });
      return this.storybookView = new App.Views.Storybook({
        model: this.storybook
      });
    });
    return it("can render an individual storybook", function() {
      var $el;
      $el = $(this.storybookView.render().el);
      return expect($el).toHaveText(/Wake up/);
    });
  });

}).call(this);
