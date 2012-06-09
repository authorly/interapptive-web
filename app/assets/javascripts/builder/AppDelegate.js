// Namespace for simulator classes
window.Builder = {
    main: function () {
        /// init director
        // var pDirector = cc.Director.sharedDirector();
        // var pScene =  pDirector.getRunningScene();
        // var scene = cc.Scene.node();

        // var for screen size
        // var s = pDirector.getWinSize()

        // add sample background image to screen
        // var sprite = cc.Sprite.spriteWithFile("assets/builder/sample.jpg");
        // sprite.setAnchorPoint(cc.ccp(0.5, 0.5));
        // sprite.setPosition(cc.ccp(s.width / 2, s.height / 2));

        // var Helloworld = cc.Layer.extend();
        // console.log(Helloworld);

        // pScene.addChild(sprite, 0);

        // Example codes, can remove upon annoyance
        // np.on('click', function () {
        //     storybook.showNextPage()
        // })
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

        Builder.main();

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