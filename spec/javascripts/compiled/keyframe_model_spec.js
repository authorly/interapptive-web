(function() {

  describe("App.Models.Keyframe", function() {
    beforeEach(function() {
      this.scene = new App.Models.Scene({
        id: 1
      });
      this.keyframe = new App.Models.Keyframe({
        id: 1,
        background_x_coord: 512,
        background_y_coord: 386,
        image_id: 3
      });
      App.currentScene(this.scene);
      return App.currentKeyframe(this.keyframe);
    });
    it("should be defined", function() {
      return expect(App.Models.Keyframe).toBeDefined();
    });
    it("can be instantiated", function() {
      var keyframe;
      keyframe = new App.Models.Keyframe();
      return expect(keyframe).not.toBeNull();
    });
    describe("when instantiated", function() {
      it("should expose the background image x coordinate attribute", function() {
        return expect(this.keyframe.get("background_x_coord")).toEqual(512);
      });
      it("should expose the background image y coordinate attribute", function() {
        return expect(this.keyframe.get("background_y_coord")).toEqual(386);
      });
      return it("should expose the background image's id attribute", function() {
        return expect(this.keyframe.get("image_id")).toEqual(3);
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
        var keyframe_response, request;
        this.keyframe.save({
          page_number: 2
        });
        request = this.server.requests[0];
        keyframe_response = JSON.parse(request.requestBody);
        expect(keyframe_response).toBeDefined();
        return expect(keyframe_response.page_number).toEqual(2);
      });
      return describe("request", function() {
        describe("on create", function() {
          beforeEach(function() {
            this.keyframe.save({
              position: 2
            });
            return this.request = this.server.requests[0];
          });
          it("should be POST", function() {});
          it("should be async", function() {
            return expect(this.request).toBeAsync();
          });
          return it("should have valid url", function() {
            return expect(this.request).toHaveUrl("/scenes/1/keyframes/1.json");
          });
        });
        return describe("on update", function() {
          beforeEach(function() {
            this.keyframe.save({
              id: 3
            });
            return this.request = this.server.requests[0];
          });
          it("should be PUT", function() {
            return expect(this.request).toBePUT();
          });
          it("should be async", function() {
            return expect(this.request).toBeAsync();
          });
          return it("should have valid url", function() {
            return expect("/scenes/1/keyframes/" + (this.keyframe.get("id")) + ".json").toEqual("/scenes/1/keyframes/3.json");
          });
        });
      });
    });
  });

}).call(this);
