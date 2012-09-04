(function() {

  describe("App.Collections.ScenesCollection", function() {
    it("should be defined", function() {
      return expect(App.Collections.ScenesCollection).toBeDefined();
    });
    return it("can be instantiated", function() {
      var scenesCollection;
      scenesCollection = new App.Collections.ScenesCollection([], {
        storybook_id: 1
      });
      return expect(scenesCollection).not.toBeNull();
    });
  });

}).call(this);
