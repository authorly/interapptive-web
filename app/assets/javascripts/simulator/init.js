/****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2011      Zynga Inc.

 http://www.cocos2d-x.org

 Created by JetBrains WebStorm.
 User: wuhao
 Date: 12-3-8

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

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

// Monkey patch to fix bugs in cocos2d-html5
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


cc.setup("simulator-canvas");
//we are ready to run the game
cc.Loader.shareLoader().onloading = function () {
    cc.LoaderScene.shareLoaderScene().draw();
};
cc.Loader.shareLoader().onload = function () {
    cc.AppController.shareAppController().didFinishLaunchingWithOptions();
};
//preload ressources
cc.Loader.shareLoader().preload([
    {type:"image", src:"/assets/simulator/HelloWorld.png"},
    {type:"image", src:"/assets/simulator/grossini_dance_07.png"},
    {type:"image", src:"/assets/simulator/cocos64.png"}
]);
