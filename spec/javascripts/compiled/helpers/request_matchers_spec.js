(function() {

  beforeEach(function() {
    return this.addMatchers({
      toBeGET: function() {
        var actual;
        actual = this.actual.method;
        return actual === "GET";
      },
      toBePOST: function() {
        var actual;
        actual = this.actual.method;
        return actual === "POST";
      },
      toBePUT: function() {
        var actual;
        actual = this.actual.method;
        return actual === "PUT";
      },
      toHaveUrl: function(expected) {
        var actual;
        actual = this.actual.url;
        this.message = function() {
          return "Expected request to have url " + expected + " but was " + actual;
        };
        return actual === expected;
      },
      toBeAsync: function() {
        var actual;
        actual = this.actual.async;
        return actual;
      }
    });
  });

}).call(this);
