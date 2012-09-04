(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  App.Views.KeyframeTextIndex = (function(_super) {

    __extends(KeyframeTextIndex, _super);

    function KeyframeTextIndex() {
      this.resize = __bind(this.resize, this);
      return KeyframeTextIndex.__super__.constructor.apply(this, arguments);
    }

    KeyframeTextIndex.prototype.texts = [];

    KeyframeTextIndex.prototype.initialize = function() {
      this.collection.on('reset', this.render, this);
      return $(window).on('resize', this.resize);
    };

    KeyframeTextIndex.prototype.render = function() {
      var c, text, _i, _len, _ref;
      this.removeTexts();
      _ref = this.collection.models;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        text = new App.Views.TextWidget({
          model: c
        });
        this.addText(text);
      }
      return this.resize();
    };

    KeyframeTextIndex.prototype.removeTexts = function() {
      var t, _i, _len, _ref;
      _ref = this.texts;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        $(t.el).remove();
      }
      return this.texts.length = 0;
    };

    KeyframeTextIndex.prototype.updateText = function() {
      var _this = this;
      return this.collection.fetch({
        success: function() {
          return _this.render();
        }
      });
    };

    KeyframeTextIndex.prototype.addText = function(text) {
      $(this.el).append(text.render().el);
      return this.texts.push(text);
    };

    KeyframeTextIndex.prototype.editText = function(text) {
      var t, _i, _len, _ref, _results;
      _ref = this.texts;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        if (t !== text) {
          t.disableEditing();
          _results.push(t.enableDragging());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    KeyframeTextIndex.prototype.createText = function(str) {
      var attributes,
        _this = this;
      attributes = {
        keyframe_id: App.currentKeyframe().get('id'),
        content: str
      };
      return this.collection.create(attributes, {
        success: function(keyframeText, response) {
          var text;
          text = new App.Views.TextWidget({
            model: keyframeText
          });
          App.currentKeyframeText(keyframeText);
          text.setPositionFromCocosCoords(300, 350);
          text.save();
          return _this.addText(text);
        }
      });
    };

    KeyframeTextIndex.prototype.resize = function() {
      var t, _i, _len, _ref, _results;
      _ref = this.texts;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        _results.push(this.positionText(t));
      }
      return _results;
    };

    KeyframeTextIndex.prototype.positionText = function(text) {
      var canvas;
      canvas = $('#builder-canvas');
      return text.setPositionFromCocosCoords(text.model.get('x_coord'), text.model.get('y_coord'));
    };

    KeyframeTextIndex.prototype.leave = function() {};

    return KeyframeTextIndex;

  })(Backbone.View);

}).call(this);
