(function() {

  describe("App.Collections.ScenesCollection", function() {
    it("should be defined", function() {
      return expect(App.Collections.ScenesCollection).toBeDefined();
    });
    it("can be instantiated", function() {
      var scenesCollection;
      scenesCollection = new App.Collections.ScenesCollection([], {
        storybook_id: 1
      });
      return expect(scenesCollection).not.toBeNull();
    });
    return describe('next available position', function() {
      beforeEach(function() {
        this.collection = new App.Collections.ScenesCollection;
        return this.scene = new App.Models.Scene;
      });
      it('should be null for a main menu scene', function() {
        this.collection.add({
          position: 0
        });
        this.scene.set({
          is_main_menu: true
        });
        return expect(this.collection.nextPosition(this.scene)).toEqual(null);
      });
      it('should be 0 for the first scene', function() {
        return expect(this.collection.nextPosition(this.scene)).toEqual(0);
      });
      it('should be the next number when there is no main menu scene', function() {
        this.collection.add({
          position: 0
        });
        this.collection.add({
          position: 1
        });
        return expect(this.collection.nextPosition(this.scene)).toEqual(2);
      });
      return it('should be the next number when there is an main menu scene', function() {
        this.collection.add({
          position: 0
        });
        this.collection.add({
          is_main_menu: true
        });
        return expect(this.collection.nextPosition(this.scene)).toEqual(1);
      });
    });
  });

}).call(this);
