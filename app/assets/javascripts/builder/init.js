var cc = cc = cc || {};

//Cocos2d directory
cc.Dir = '../cocos2d/';//in relate to the html file or use absolute
cc.loadQue = [];//the load que which js files are loaded
cc.COCOS2D_DEBUG = 2;
cc._DEBUG = 1;
cc._IS_RETINA_DISPLAY_SUPPORTED = 0;

//html5 selector method
cc.$ = function (x) {
    return document.querySelector(x);
};
cc.$new = function (x) {
    return document.createElement(x);
};
cc.Log = cc.LOG = console.log.bind(console)
cc.TransitionScene = function () {
};

window.runBuilder = function () {
    // Monkey patch to fix bugs in cocos2d-html5 -- it can't add to DOM correctly
    cc.setupHTML = function(a){
        var b = cc.canvas;
        b.style.zIndex = 0;
        var c = cc.$new("div");
        c.id = "Cocos2dGameContainer";
        c.style.overflow = "hidden";
        c.style.height = b.clientHeight + "px";
        c.style.width = b.clientWidth + "px";
        a && c.setAttribute("fheight", a.getContentSize().height);
        a = cc.$new("div");
        a.id = "domlayers";
        c.appendChild(a);
        b.parentNode.insertBefore(c, b);
        c.appendChild(b);

        return a
    };

    // Monkey patch to fix bug in touch calculation in cocos2d-html5
    cc.Touch.prototype.locationInView = function () {
        var p = this._m_point;


        // Ratio of canvas to element size
        var ratioW = cc.canvas.width / $(cc.canvas).width()
            , ratioH = cc.canvas.height / $(cc.canvas).height()

        // Fix coords ignoring scroll
        var scrollV = 0
            , scrollH = 0
        var x = $(cc.canvas)
        while (x.length > 0) {
            scrollV += x.scrollTop()
            scrollH += x.scrollLeft()

            x = x.parent()
        }

        // X coord doesn't consider ratio
        var realX = (p.x - scrollH) * ratioW

        // Y coord has wrong origin and doesn't consider ratio
        var realY = (p.y - (cc.canvas.height - $(cc.canvas).height())) - scrollV
        realY *= ratioH

        var actualPoint = new cc.Point(realX, realY)

        return actualPoint
    }

    cc.setup("builder-canvas");

    //we are ready to run the game
    cc.Loader.shareLoader().onloading = function () {
        // cc.LoaderScene.shareLoaderScene().draw();
        console.log("LOADING....");
    };

    cc.Loader.shareLoader().onload = function () {
        cc.AppController.shareAppController().didFinishLaunchingWithOptions();
    };

    //preload ressources
    cc.Loader.shareLoader().preload([
        {type:"image", src:"/assets/builder/sample.jpg"}
    ])
}