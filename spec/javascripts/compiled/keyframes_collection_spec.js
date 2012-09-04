(function() {

  describe("App.Collections.KeyframesCollection", function() {
    it("should be defined", function() {
      return expect(App.Collections.KeyframesCollection).toBeDefined();
    });
    return it("can be instantiated", function() {
      var keyframesCollection;
      keyframesCollection = new App.Collections.KeyframesCollection([], {
        scene_id: 1
      });
      return expect(keyframesCollection).not.toBeNull();
    });
  });

}).call(this);
