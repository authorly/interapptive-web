(function() {

  describe("App.Models.Scene", function() {
    beforeEach(function() {
      this.storybook = new App.Models.Storybook({
        id: 1
      });
      this.scene = new App.Models.Scene({
        image_id: 1,
        sound_id: 2,
        preview_image_id: 3,
        page_number: 1
      }, {
        collection: this.storybook.scenes
      });
      App.currentSelection.set({
        storybook: this.storybook
      });
      return App.currentSelection.set({
        scene: this.scene
      });
    });
    it("should be defined", function() {
      return expect(App.Models.Scene).toBeDefined();
    });
    describe("when instantiated", function() {
      it("should expose the background image id attribute", function() {
        return expect(this.scene.get("image_id")).toEqual(1);
      });
      it("should expose the sound_id attribute", function() {
        return expect(this.scene.get("sound_id")).toEqual(2);
      });
      it("should expose the preview_image_id attribute", function() {
        return expect(this.scene.get("preview_image_id")).toEqual(3);
      });
      return it("should expose the page number attribute", function() {
        return expect(this.scene.get("page_number")).toEqual(1);
      });
    });
    return describe("#save", function() {
      beforeEach(function() {
        return this.server = sinon.fakeServer.create();
      });
      afterEach(function() {
        return this.server.restore();
      });
      it("sends valid data to the server", function() {
        var request, scene_response;
        this.scene.save({
          page_number: 2
        });
        request = this.server.requests[0];
        scene_response = JSON.parse(request.requestBody);
        expect(scene_response).toBeDefined();
        return expect(scene_response.page_number).toEqual(2);
      });
      return describe("request", function() {
        describe("on create", function() {
          beforeEach(function() {
            this.scene.save();
            return this.request = this.server.requests[0];
          });
          it("should be POST", function() {
            return expect(this.request).toBePOST();
          });
          it("should be async", function() {
            return expect(this.request).toBeAsync();
          });
          return it("should have valid url", function() {
            return expect(this.request).toHaveUrl('/storybooks/1/scenes.json');
          });
        });
        return describe("on update", function() {
          beforeEach(function() {
            this.scene.set("id", 3);
            this.scene.save();
            return this.request = this.server.requests[0];
          });
          it("should be PUT", function() {
            return expect(this.request).toBePUT();
          });
          it("should be async", function() {
            return expect(this.request).toBeAsync();
          });
          return it("should have valid url", function() {
            return expect("/storybooks/" + (this.storybook.get("id")) + "/scenes/" + (this.scene.get("id")) + ".json").toEqual("/storybooks/1/scenes/3.json");
          });
        });
      });
    });
  });

}).call(this);
