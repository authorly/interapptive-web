(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  App.Builder.Widgets.WidgetLayer = (function(_super) {

    __extends(WidgetLayer, _super);

    function WidgetLayer() {
      var _this = this;
      WidgetLayer.__super__.constructor.apply(this, arguments);
      this.widgets = [];
      this._capturedWidget = null;
      this._selectedWidget = null;
      this.setIsTouchEnabled(true);
      cc.canvas.addEventListener('dblclick', function(event) {
        var el, mouseX, mouseY, pos, touch, tx, ty, widget;
        el = cc.canvas;
        pos = {
          left: 0,
          top: 0,
          height: el.height
        };
        while (el !== null) {
          pos.left += el.offsetLeft;
          pos.top += el.offsetTop;
          el = el.offsetParent;
        }
        tx = event.pageX;
        ty = event.pageY;
        mouseX = (tx - pos.left) / cc.Director.sharedDirector().getContentScaleFactor();
        mouseY = (pos.height - (ty - pos.top)) / cc.Director.sharedDirector().getContentScaleFactor();
        touch = new cc.Touch(0, mouseX, mouseY);
        touch._setPrevPoint(cc.TouchDispatcher.preTouchPoint.x, cc.TouchDispatcher.preTouchPoint.y);
        cc.TouchDispatcher.preTouchPoint.x = mouseX;
        cc.TouchDispatcher.preTouchPoint.y = mouseY;
        widget = _this.widgetAtPoint(touch.locationInView());
        return widget.trigger('dblclick', touch, event);
      });
    }

    WidgetLayer.prototype.clearWidgets = function() {
      var widget, _i, _len, _ref;
      _ref = this.widgets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        widget = _ref[_i];
        if (widget.type !== "TextWidget") {
          this.removeChild(widget);
        }
      }
      return this.widgets.splice(0);
    };

    WidgetLayer.prototype.addWidget = function(widget) {
      this.widgets.push(widget);
      this.addChild(widget);
      App.storybookJSON.addWidget(App.currentKeyframe(), widget);
      return this;
    };

    WidgetLayer.prototype.widgetAtTouch = function(touch) {
      return this.widgetAtPoint(touch.locationInView());
    };

    WidgetLayer.prototype.widgetAtPoint = function(point) {
      var local, r, widget, _i, _len, _ref;
      _ref = this.widgets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        widget = _ref[_i];
        if (widget instanceof App.Views.TextWidget) {
          continue;
        }
        if (widget.getIsVisible()) {
          local = widget.convertToNodeSpace(point);
          r = widget.rect();
          r.origin = new cc.Point(0, 0);
          local.x += this.getAnchorPoint().x * r.size.width;
          local.y += this.getAnchorPoint().y * r.size.height;
          if (cc.Rect.CCRectContainsPoint(r, local)) {
            return widget;
          }
        }
      }
      return null;
    };

    WidgetLayer.prototype.ccTouchesBegan = function(touches) {
      var touch, widget;
      widget = this.widgetAtTouch(touches[0]);
      if (!widget) {
        return;
      }
      widget.trigger('mousedown');
      touch = touches[0].locationInView();
      this._capturedWidget = widget;
      this._previousPoint = new cc.Point(touch.x, touch.y);
      return true;
    };

    WidgetLayer.prototype.ccTouchesMoved = function(touches) {
      var point;
      point = touches[0].locationInView();
      this.mouseOverWidgetAtPoint(point);
      if (this._capturedWidget) {
        this.moveCapturedWidget(point);
        return App.builder.canDragBackground = false;
      }
    };

    WidgetLayer.prototype.ccTouchesEnded = function(touches) {
      if (this._capturedWidget) {
        this._capturedWidget.trigger('change', 'position');
      }
      if (this._capturedWidget) {
        this._capturedWidget.trigger('mouseup');
      }
      delete this._previousPoint;
      delete this._capturedWidget;
      if (App.builder.canDragBackground === false) {
        return App.builder.canDragBackground = true;
      }
    };

    WidgetLayer.prototype.moveCapturedWidget = function(point) {
      var delta, newPos;
      this._previousPoint || (this._previousPoint = point);
      delta = cc.ccpSub(point, this._previousPoint);
      newPos = cc.ccpAdd(delta, this._capturedWidget.getPosition());
      this._capturedWidget.setPosition(newPos, false);
      return this._previousPoint = new cc.Point(point.x, point.y);
    };

    WidgetLayer.prototype.mouseOverWidgetAtPoint = function(point) {
      var widget;
      widget = this.widgetAtPoint(point);
      if (widget !== this._mouseOverWidget) {
        if (this._mouseOverWidget) {
          this._mouseOverWidget.trigger('mouseout');
        }
        if (widget) {
          widget.trigger('mouseover');
        }
        return this._mouseOverWidget = widget;
      }
    };

    return WidgetLayer;

  })(cc.Layer);

}).call(this);
