(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  App.Models.Keyframe = (function(_super) {

    __extends(Keyframe, _super);

    function Keyframe() {
      return Keyframe.__super__.constructor.apply(this, arguments);
    }

    Keyframe.prototype.paramRoot = 'keyframe';

    Keyframe.prototype.url = function() {
      var base;
      base = '/scenes/' + App.currentScene().get('id') + '/';
      if (this.isNew()) {
        return base + 'keyframes.json';
      }
      return base + 'keyframes/' + App.currentKeyframe().get('id') + '.json';
    };

    Keyframe.prototype.addWidget = function(widget) {
      var widgets;
      widgets = this.get('widgets') || [];
      widgets.push(widget.toHash());
      this.set('widgets', widgets);
      return this.save();
    };

    Keyframe.prototype.updateWidget = function(widget) {
      var i, w, widgets, _i, _len;
      widgets = this.get('widgets') || [];
      for (i = _i = 0, _len = widgets.length; _i < _len; i = ++_i) {
        w = widgets[i];
        if (widget.id === w.id) {
          widgets[i] = widget.toHash();
          this.set('widgets', widgets);
          this.save();
          return;
        }
      }
      return this.addWidget(widget);
    };

    Keyframe.prototype.removeWidget = function(widget) {
      var i, w, widgets, _i, _len, _results;
      widgets = this.get('widgets');
      if (widgets == null) {
        return;
      }
      _results = [];
      for (i = _i = 0, _len = widgets.length; _i < _len; i = ++_i) {
        w = widgets[i];
        if (w.id === widget.id) {
          widgets.splice(i, 1);
          this.set('widgets', widgets);
          this.save();
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Keyframe;

  })(Backbone.Model);

  App.Collections.KeyframesCollection = (function(_super) {

    __extends(KeyframesCollection, _super);

    function KeyframesCollection() {
      return KeyframesCollection.__super__.constructor.apply(this, arguments);
    }

    KeyframesCollection.prototype.model = App.Models.Keyframe;

    KeyframesCollection.prototype.paramRoot = 'keyframe';

    KeyframesCollection.prototype.initialize = function(models, options) {
      if (options) {
        return this.scene_id = options.scene_id;
      }
    };

    KeyframesCollection.prototype.url = function() {
      return '/scenes/' + this.scene_id + '/keyframes.json';
    };

    KeyframesCollection.prototype.ordinalUpdateUrl = function(sceneId) {
      return '/scenes/' + sceneId + '/keyframes/sort.json';
    };

    KeyframesCollection.prototype.toModdedJSON = function() {
      return {
        "keyframes": this.toJSON()
      };
    };

    KeyframesCollection.prototype.comparator = function(keyframe) {
      return keyframe.get('position');
    };

    return KeyframesCollection;

  })(Backbone.Collection);

}).call(this);
