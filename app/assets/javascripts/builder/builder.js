(function() {
  var Builder,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Builder = (function(_super) {

    __extends(Builder, _super);

    Builder.prototype.isMouseDown = false;

    Builder.prototype.backgroundSprite = null;

    Builder.prototype.book = null;

    Builder.prototype.canDragBackground = true;

    function Builder() {
      Builder.__super__.constructor.apply(this, arguments);
      this.setIsTouchEnabled(true);
      this.widgetLayer = new App.Builder.Widgets.WidgetLayer;
      this.addChild(this.widgetLayer, 100);
    }

    Builder.prototype.ccTouchesBegan = function(touches, event) {
      return this.isMouseDown = true;
    };

    Builder.prototype.ccTouchesMoved = function(touches, event) {
      var currentPointerPosition;
      if (this.canDragBackground) {
        currentPointerPosition = new cc.Point(touches[0].locationInView(0).x, touches[0].locationInView(0).y);
        if (touches && this.isMouseDown) {
          return this.backgroundSprite.setPosition(currentPointerPosition);
        }
      }
    };

    Builder.prototype.ccTouchesEnded = function(touches, event) {
      var touchLocation;
      this.isMouseDown = false;
      touchLocation = touches[0].locationInView(0);
      App.keyframeListView.setBackgroundPosition(parseInt(touchLocation.x), parseInt(touchLocation.y));
      App.keyframeListView.setThumbnail();
      if (this.backgroundSprite) {
        return App.storybookJSON.updateSprite(App.currentScene(), this.backgroundSprite);
      }
    };

    return Builder;

  })(cc.Layer);

  Builder.scene = function() {
    var layer, scene;
    scene = cc.Scene.node();
    layer = this.node();
    scene.addChild(layer);
    return scene;
  };

  Builder.node = function() {
    var ret;
    ret = new Builder();
    if (ret && ret.init()) {
      return ret;
    }
    return null;
  };

  window.Builder = Builder;

}).call(this);
