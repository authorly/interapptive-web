var Builder = cc.Layer.extend({
    isMouseDown: false,
    paragraphText: null,
    backgroundSprite: null,

    init: function () {
        this._super();
        this.setIsTouchEnabled(true);

        this.addChild(new App.Builder.Widgets.TouchEditorLayer, 100)
        return true;
    },

    ccTouchesBegan: function (touches, event) {
        this.isMouseDown = true;
    },


    ccTouchesMoved: function (touches, event) {
        if (this.isMouseDown) {
            if (touches) {
                this.backgroundSprite.setPosition(new cc.Point(touches[0].locationInView(0).x, touches[0].locationInView(0).y));
            }
        }
    },

    ccTouchesEnded: function (touches, event) {
        this.isMouseDown = false;
    },

    ccTouchesCancelled: function (touches, event) {
        console.log("ccTouchesCancelled");
    }
});

Builder.scene = function () {
    // 'scene' is an autorelease object
    var scene = cc.Scene.node();

    // 'layer' is an autorelease object
    var layer = this.node();
    scene.addChild(layer);
    return scene;
};

// implement the "static node()" method manually
Builder.node = function () {
    var ret = new Builder();

    // Init the Builder display layer.
    if (ret && ret.init()) {
        return ret;
    }

    return null;
};
