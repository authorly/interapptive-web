(function() {

  describe("Interapptive", function() {
    it("has a namespace for Models", function() {
      return expect(App.Models).toBeTruthy();
    });
    it("has a namespace for Collections", function() {
      return expect(App.Collections).toBeTruthy();
    });
    it("has a namespace for Views", function() {
      return expect(App.Views).toBeTruthy();
    });
    it("has a namespace for Routers", function() {
      return expect(App.Routers).toBeTruthy();
    });
    return describe("initialize()", function() {
      return it("accepts data JSON and instantiates a collection from it", function() {
        var data;
        data = {
          storybooks: [
            {
              title: "thing to do"
            }, {
              title: "another thing"
            }
          ],
          users: [
            {
              id: "1",
              email: "alice@example.com"
            }
          ]
        };
        App.initialize;
        App.storybooks = data;
        expect(App.storybooks.storybooks).not.toEqual(undefined);
        expect(App.storybooks.storybooks.length).toEqual(2);
        expect(App.storybooks.storybooks[0].title).toEqual("thing to do");
        return expect(App.storybooks.storybooks[1].title).toEqual("another thing");
      });
    });
  });

}).call(this);
