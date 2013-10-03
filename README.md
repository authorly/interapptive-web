# Welcome to Authorly

## Here be Dragons

## Setup the application

1. Clone the repository on your machine
1. Install [sox](http://sox.sourceforge.net/) version 14.4.0. On ubuntu, you will have to install `libsox-fmt-mp3` to support mp3 files with sox.

	If you don't want to install `sox`, or you cannot get `libmad` &amp; `sox` to play together): comment out `process :convert_audio => args` in `lib/interapptive/carrier_wave/sphinx_audio_converter.rb`
1. Create a suitable `config/database.yml` (production will likely run on MySQL)
1. `bundle install`
1. `bundle exec rake db:create:all`
1. `bundle exec rake db:migrate`
1. `bundle exec rake db:seed`
1. `bundle exec rails server` starts the server


## Setup for getting transcoded video versions

  `bundle exec zencoder_fetcher --loop --interval 10 --url 'http://127.0.0.1:3000/zencoder' <ZENCODER_API_KEY>`


## Setup for creating mobile applications

Install dependencies:

1. Install [redis](http://redis.io/)
1. Clone the mobile code

     cd ../..
     git clone git@github.com:curiousminds/interapptive.git
     mv interapptive Crucible

Start workers:

1. `redis-server` starts redis
1. `bundle exec rake environment resque:work QUEUE='ios_compilation' RAILS_ENV=development` starts the compilation queue


Start compilation from the web application (currently: 'File' menu -> 'Compile to iOS'). Currently does not work because the code assumes it is run by a certain user, needs the keychain password in `config/keychain_password.txt`.
Stopped trying to make this work on my machine. `2013-06-19` `@dira`


## Tests

### Rails tests

    `bundle exec rake`

Continuous testing:

    `bundle exec guard -i`

### Javascript tests

1. Install [PhantomJS](https://github.com/netzpirat/guard-jasmine#phantomjs)


In the browser:

    `bundle exec guard -i`

The output contains the URL where it mounted the jasmine runner (something like http://localhost:[port]/jasmine).
That URL works in the browser and you have the full UI (i.e. you can click on a test and it will only run that test)


Command line:

    `guard-jasmine`

    or

    `bundle exec rake guard:jasmine`


### Write Javascript tests

Write your model, view or collections tests under corresponding directories inside `spec/javascripts/coffeescripts`.

## Builder

### Synopsis

Builder is a custom widget framework/base class that provides a relevant API for making and running different type of widgets, which are objects that can be  added to the canvas. Builder abstracts cocos2d-js which is a two-dimensional drawing library that's primarily used functionally. In this way, Builder provides a nice inheritable OO interface, which is great for testing and great for reuse.

Find it in `app/assets/javascripts/builder/`.

### Some important Cocos2d Concepts

First, you should see [this link](http://www.cocos2d.org/doc/programming_guide/basic_concepts.html) for more information about the core concepts of Cocos.

To summarize, however:

- A **scene** is pretty self-explanatory. Think levels on a video game, or multiple, independent televisions screens. They're mostly independent of each other, but they have some logic for transitioning between each other
- The **director**, a singleton object that handles transitions between scenes, and handles main window instantiation in py-cocos2d;
- **Layers** are used to handle z-orientation of groups of items. Frequently are the location where event handlers are defined, and respond to events from front to back until one layer handles an event.
- **Sprites** are 2d images that can be transformed.
- **Events** are part of a standard Subscribe pattern. In short, some items act as emitters, which send out notifications when they receive certain stimulus. Other objects that have subscribed to the notifications will receive this notification and can chose to respond to it (called Listeners, usually).
    - Cocos uses events to specify user input, window status change, and to communicate across parts of a framework (decoupling).
- **CocosNode** is the superclass of the above (omitting the director?), and provides some default common functionality like positioning, controlling child elements, time management, and rendering.

`cc` is the Cocos2d namespace.

### Widgets

`WidgetLayer` manages the widget space and mouse/touch interactions.

Widgets are represented by two classes - a Backbone Model (that stores and manages the widget data) and a Builder View (which takes care of representing it on the UI and managing events).

Widget states:

* `default` The widget is displayed in its regular state
* `selected` The widget is selected to be edited. Hotspots and sprites can be resized, Text allows changing the text. The widget is displayed in a distinctive way (blue border around hotspots and sprites, together with resize controls; text widgets have a dashed border and allow entering text.
* `hovered` The widget is the top-most widget under the mouse. It can be moved by dragging (and this does not affect the selected widget). It cannot be resized or edited in other ways. It is displayed in a distinctive way (blue border around hotspots and sprites, different color for text).

There can be at most one `selected` and at most one `hovered` widget at a time.

Widget state transitions:

* Clicking on a widget gets it to `selected` (and puts the previously selected widget, it present, into `default`).
* Clicking in the canvas, but not on a widget, puts the previously selected widget, it present, into `default`.
* Moving the mouse over a widget gets it to `hovered` (and puts the previously hovered widget, it present, into `default`).
* Moving the mouse within the canvas, but not on a widget, puts the previously hovered widget, it present, into `default`.

### Fixtures

Reside in /spec/fixtures

Loading:

    > cp spec/fixtures/stranger-in-the-woods.yml db/data.yml
    > bundle exec rake db:data:load


Grab the JSON - in the web inspector console:

    > storybook = App.currentSelection.get('storybook')
    > json = (new App.JSON(storybook)).app
    > JSON.stringify(json)

Run the iOS simulator:

* copy the json from the web inspector console (without the encompassing quotes)
* paste it over `HelloWorld/Resources/structure-ipad.json` (in the `interapptive` project)
* fix the asset paths by running

    > sed -i '' 's/read_it_myself/read-it-myself/g;s/auto_play/autoplay/g;s/read_to_me/read-to-me/g;s/\/assets\/sprites\///g;s/https:\/\/interapptive.s3.amazonaws.com\/[a-z_]*\/[0-9]*\///g' HelloWorld/Resources/structure-ipad.json
* run the iOS project ( `HelloWorld/ios` in the interraptive repo)
