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

/**
 @brief    The cocos2d Application.

 The reason for implement as private inheritance is to hide some interface call by CCDirector.
 */

cc.AppDelegate = cc.Application.extend({
    ctor:function () {
        this._super();
    },
    /**
     @brief    Implement for initialize OpenGL instance, set source path, etc...
     */
    initInstance:function () {
        return true;
    },

    /**
     @brief    Implement CCDirector and CCScene init code here.
     @return true    Initialize success, app continue.
     @return false   Initialize failed, app terminate.
     */
    applicationDidFinishLaunching:function () {
        // initialize director
        var pDirector = cc.Director.sharedDirector();

        // turn on display FPS
        pDirector.setDisplayFPS(true);

        // pDirector->setDeviceOrientation(kCCDeviceOrientationLandscapeLeft);

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

    /**
     @brief  The function be called when the application enter background
     @param  the pointer of the application
     */
    applicationDidEnterBackground:function () {
        cc.Director.sharedDirector().pause();
    },

    /**
     @brief  The function be called when the application enter foreground
     @param  the pointer of the application
     */
    applicationWillEnterForeground:function () {
        cc.Director.sharedDirector().resume();
    }
});