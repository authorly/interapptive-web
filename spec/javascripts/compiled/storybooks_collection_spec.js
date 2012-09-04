(function() {

  describe("App.Collections.StorybooksCollection", function() {
    it("should be defined", function() {
      return expect(App.Collections.StorybooksCollection).toBeDefined();
    });
    return it("can be instantiated", function() {
      var storybooksCollection;
      storybooksCollection = new App.Collections.StorybooksCollection();
      return expect(storybooksCollection).not.toBeNull();
    });
  });

}).call(this);
