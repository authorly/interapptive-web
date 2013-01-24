(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  App.Models.Font = (function(_super) {

    __extends(Font, _super);

    function Font() {
      return Font.__super__.constructor.apply(this, arguments);
    }

    Font.prototype.url = function() {
      return '/storybooks/' + App.currentSelection.get('storybook').get("id") + '/scenes/' + App.currentSelection.get('scene').get("id") + '/fonts.json';
    };

    Font.prototype.toString = function() {
      return this.get('name');
    };

    return Font;

  })(Backbone.Model);

  App.Collections.FontsCollection = (function(_super) {

    __extends(FontsCollection, _super);

    function FontsCollection() {
      this.toSelectOptionGroup = __bind(this.toSelectOptionGroup, this);
      return FontsCollection.__super__.constructor.apply(this, arguments);
    }

    FontsCollection.prototype.model = App.Models.Font;

    FontsCollection.prototype.url = function() {
      return "/storybooks/" + App.currentSelection.get('storybook').get('id') + "/fonts.json";
    };

    FontsCollection.prototype.toSelectOptionGroup = function(callback) {
      var onSuccess;
      onSuccess = function(collection) {
        var clx;
        return callback(clx = collection.map(function(model) {
          return model.toSelectOption();
        }), clx.unshift({
          val: '',
          label: ''
        }), clx);
      };
      return this.fetch({
        success: function(collection, response) {
          return onSuccess(collection);
        }
      });
    };

    return FontsCollection;

  })(Backbone.Collection);

}).call(this);
