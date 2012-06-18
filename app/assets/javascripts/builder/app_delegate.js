// Namespace for builder classes
App.Builder = {
    main: function (scene) {
        var pDirector = cc.Director.sharedDirector()
          , s = pDirector.getWinSize()
          , ret = new Builder.node();

        cc.Director.sharedDirector().replaceScene(ret);
    }
}

var cc = cc = cc || {};

cc.AppDelegate = cc.Application.extend({
    ctor:function () {
        this._super();
    },

    initInstance:function () {
        return true;
    },

    applicationDidFinishLaunching:function () {
        // initialize director
        var pDirector = cc.Director.sharedDirector();

        // turn on display FPS
        pDirector.setDisplayFPS(true);

        // set FPS. the default value is 1.0/60 if you don't call this
        pDirector.setAnimationInterval(1.0 / 60);

        // create a scene. it's an autorelease object
        var pScene = new cc.Scene();

        // add label to the screen
        var label = cc.LabelTTF.labelWithString("Builder ready", "Arial", 24)
        label.setColor(new cc.Color3B(255, 0, 0));
        var s = pDirector.getWinSize();
        label.setPosition(new cc.Point(s.width / 2, s.height / 2));

        pScene.addChild(label);

        // run
        pDirector.runWithScene(pScene);

        App.Builder.main(pScene);

        return true;
    },

    applicationDidEnterBackground:function () {
        cc.Director.sharedDirector().pause();
    },

    applicationWillEnterForeground:function () {
        cc.Director.sharedDirector().resume();
    }
});