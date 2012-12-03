(function() {

  describe("App.Collections.KeyframesCollection", function() {
    it("should be defined", function() {
      return expect(App.Collections.KeyframesCollection).toBeDefined();
    });
    it("can be instantiated", function() {
      var keyframesCollection;
      keyframesCollection = new App.Collections.KeyframesCollection([], {
        scene_id: 1
      });
      return expect(keyframesCollection).not.toBeNull();
    });
    describe('next available position', function() {
      beforeEach(function() {
        this.collection = new App.Collections.KeyframesCollection;
        sinon.stub(this.collection, 'announceAnimation');
        return this.keyframe = new App.Models.Keyframe;
      });
      it('should be null for an animationkeyframe', function() {
        this.collection.add({
          position: 0
        });
        this.keyframe.set({
          is_animation: true
        });
        return expect(this.collection.nextPosition(this.keyframe)).toEqual(null);
      });
      it('should be 0 for the first keyframe', function() {
        return expect(this.collection.nextPosition(this.keyframe)).toEqual(0);
      });
      it('should be the next number when there is no animation keyframe', function() {
        this.collection.add({
          position: 0
        });
        this.collection.add({
          position: 1
        });
        return expect(this.collection.nextPosition(this.keyframe)).toEqual(2);
      });
      return it('should be the next number when there is an animation keyframe', function() {
        this.collection.add({
          position: 0
        });
        this.collection.add({
          is_animation: true
        });
        return expect(this.collection.nextPosition(this.keyframe)).toEqual(1);
      });
    });
    return describe('recalculate positions', function() {
      return describe('on destroy', function() {
        beforeEach(function() {
          this.server = sinon.fakeServer.create();
          this.collection = new App.Collections.KeyframesCollection;
          sinon.stub(this.collection, 'announceAnimation');
          this.collection.add({
            title: '0',
            position: 0
          });
          this.collection.add({
            title: '1',
            position: 1
          });
          this.collection.add({
            title: '2',
            position: 2
          });
          return this.collection.add({
            title: 'animation',
            is_animation: true
          });
        });
        afterEach(function() {
          return this.server.restore();
        });
        return it('should recalculate positions correctly', function() {
          this.collection.remove(this.collection.at(2));
          expect(this.collection.at(0).get('position')).toEqual(null);
          expect(this.collection.at(1).get('position')).toEqual(0);
          return expect(this.collection.at(2).get('position')).toEqual(1);
        });
      });
    });
  });

}).call(this);
