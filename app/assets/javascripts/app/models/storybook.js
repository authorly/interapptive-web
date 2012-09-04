(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  App.Models.Storybook = (function(_super) {
    var checkAuthor, checkDesc, checkPrice, checkTitle;

    __extends(Storybook, _super);

    function Storybook() {
      return Storybook.__super__.constructor.apply(this, arguments);
    }

    Storybook.prototype.schema = {
      title: {
        type: "Text",
        title: "Story Title",
        validators: [
          "required", checkTitle = function(value, formValues) {
            var err;
            err = {
              type: "title",
              message: "Oops! Title must be 2-25 characters"
            };
            if (value.length < 3 || value.length > 25) {
              return err;
            }
          }
        ]
      },
      price: {
        title: "Price",
        type: "Currency",
        template: "currencyField",
        validators: [
          "required", checkPrice = function(value, formValues) {
            var err;
            err = {
              type: "price",
              message: "Must be non-negative and less than $100.00"
            };
            if (value < 0 || value > 100) {
              return err;
            }
          }
        ]
      },
      author: {
        title: "Author",
        type: "Text",
        validators: [
          "required", checkAuthor = function(value, formValues) {
            var err;
            err = {
              type: "author",
              message: "Oops! Author field must be 2-25 characters."
            };
            if (value.length < 3 || value.length > 50) {
              return err;
            }
          }
        ]
      },
      description: {
        title: "Description",
        type: "Text",
        validators: [
          "required", checkDesc = function(value, formValues) {
            var err;
            err = {
              type: "description",
              message: "App description must be 10-25 characters."
            };
            if (value.length < 3 || value.length > 25) {
              return err;
            }
          }
        ]
      },
      published_on: {
        title: "Published on",
        type: "Date"
      },
      android_or_ios: {
        title: "Mobile Platform",
        type: "Buttons",
        buttonType: "radio",
        labeling: ["iOS", "Both", "Android"],
        selectedIndex: 1
      },
      record_enabled: {
        title: "Enable voice recording?",
        help: "Allows your users to record, use, and share voice-overs",
        type: "Buttons",
        buttonType: "radio",
        labeling: ["On", "Off"],
        selectedIndex: 0
      }
    };

    Storybook.prototype.url = function() {
      if (this.isNew()) {
        return '/storybooks.json';
      }
      return '/storybooks/' + App.currentStorybook().get("id") + '.json';
    };

    Storybook.prototype.toJSON = function() {
      return this.attributes;
    };

    return Storybook;

  })(Backbone.Model);

  App.Collections.StorybooksCollection = (function(_super) {

    __extends(StorybooksCollection, _super);

    function StorybooksCollection() {
      return StorybooksCollection.__super__.constructor.apply(this, arguments);
    }

    StorybooksCollection.prototype.model = App.Models.Storybook;

    StorybooksCollection.prototype.url = function() {
      return '/storybooks.json';
    };

    StorybooksCollection.prototype.comparator = function(storybook) {
      return new Date(storybook.get('created_at'));
    };

    return StorybooksCollection;

  })(Backbone.Collection);

}).call(this);
