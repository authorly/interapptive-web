(function() {

  describe("App.Models.Storybook", function() {
    beforeEach(function() {
      return this.storybook = new App.Models.Storybook({
        title: "Storybook Title",
        price: 3.99,
        author: "Author Write",
        description: "Storybook app description",
        published_on: "2012-08-19 08:09:27",
        android_or_ios: "both",
        record_enabled: true
      });
    });
    it("should be defined", function() {
      return expect(App.Models.Storybook).toBeDefined();
    });
    it("can be instantiated", function() {
      return expect(this.storybook).not.toBeNull();
    });
    describe("when instantiated", function() {
      it("should expose the model's title attribute", function() {
        return expect(this.storybook.get("title")).toEqual("Storybook Title");
      });
      it("should expose the model's price attribute", function() {
        return expect(this.storybook.get("price")).toEqual(3.99);
      });
      it("should expose the model's author attribute", function() {
        return expect(this.storybook.get("author")).toEqual("Author Write");
      });
      it("should expose the model's description attribute", function() {
        return expect(this.storybook.get("description")).toEqual("Storybook app description");
      });
      it("should expose the model's publish date attribute", function() {
        return expect(this.storybook.get("published_on")).toEqual("2012-08-19 08:09:27");
      });
      it("should expose an attribute for setting target platform for compilation", function() {
        return expect(this.storybook.get("android_or_ios")).toEqual("both");
      });
      return it("should expose the model's  voice recording option attribute", function() {
        return expect(this.storybook.get("record_enabled")).toEqual(true);
      });
    });
    describe("attribute validation", function() {
      beforeEach(function() {
        var form, storybook;
        storybook = new App.Models.Storybook();
        App.currentStorybook(storybook);
        form = new App.Views.AppSettings().form;
        return this.errors = form.commit();
      });
      it("should require a title", function() {
        return expect(this.errors.title.message).toEqual("Required");
      });
      it("should require a price", function() {
        return expect(this.errors.price.message).toEqual("Required");
      });
      it("should require a description", function() {
        return expect(this.errors.description.message).toEqual("Required");
      });
      return it("should require a author", function() {
        return expect(this.errors.author.message).toEqual("Required");
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
        var request, storybook_response;
        this.storybook.save({
          title: "A new storybook title"
        });
        request = this.server.requests[0];
        storybook_response = JSON.parse(request.requestBody);
        expect(storybook_response).toBeDefined();
        return expect(storybook_response.title).toEqual("A new storybook title");
      });
      return describe("request", function() {
        describe("on create", function() {
          beforeEach(function() {
            this.storybook.id = null;
            this.storybook.save();
            return this.request = this.server.requests[0];
          });
          it("should be POST", function() {
            return expect(this.request).toBePOST();
          });
          it("should be async", function() {
            return expect(this.request).toBeAsync();
          });
          return it("should have valid url", function() {
            return expect(this.request).toHaveUrl('/storybooks.json');
          });
        });
        return describe("on update", function() {
          beforeEach(function() {
            this.storybook.id = 3;
            this.storybook.save();
            return this.request = this.server.requests[0];
          });
          it("should be PUT", function() {
            return expect(this.request).toBePUT();
          });
          return it("should be async", function() {
            return expect(this.request).toBeAsync();
          });
        });
      });
    });
  });

}).call(this);
