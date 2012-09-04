(function() {

  describe("App.Views.StorybookIndex", function() {
    beforeEach(function() {
      this.storybookCollection = new App.Collections.StorybooksCollection();
      return this.view = new App.Views.StorybookIndex({
        collection: this.storybookCollection
      });
    });
    return describe("Instantiation", function() {
      return it("should create a container for the list element", function() {
        return expect(this.view.el.nodeName).toEqual("DIV");
      });
    });
  });

}).call(this);
