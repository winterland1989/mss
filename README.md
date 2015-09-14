MSS: messed up style sheet
==========================

Write CSS in a functional way with pure javascript.  Check out the [online compiler](http://winterland1989.github.io/mss).

Intro
-----

MSS.parse takes a mss object as input and output a css string

+ A mss object is a plain javascript object, usually nested

+ A key will be a CSS selector if its value is another mss object, otherwise it will be taken as a property name for CSS

+ MSS will parse the nested object into nested selectors by connnecting selectors into a descendant selector

Let's see an example:

```javascript
mss = {
  FooClass: {
    zIndex: 999,
    $BarId_AnotherClass: {
      MozBoxShadow: '10px 10px 5px #888',
      input: {
        borderRadius: '12px',
        padding: '12px',
        width: '100%'
      }
    }
  }
};

// set second argmument to true to enable prettify
console.log(MSS.parse(mss, true));

```

will yield:

```css
.FooClass #barId input,
.FooClass .AnotherClass input{
  border-radius:12px;
  padding:12px;
  width:100%;
}
.FooClass #barId,
.FooClass .AnotherClass{
  -moz-box-shadow:10px 10px 5px #888;
}
.FooClass{
  z-index:999;
}
```

As shown above, the selectors and prop name are converted for the writing ease in Javascript(using valid variable as much as possible) 

As a coffeescript user, i would write former example in coffeescript:

```coffee
mss =
    FooClass:
        zIndex: 999
        $BarId_AnotherClass:
            MozBoxShadow: '10px 10px 5px #888888'
            Input:
                borderRadius: '12px'
                padding: '12px'
                width: '100%'   
                
console.log MSS.parse(mss, true)
```

Much nicer! For the sake of clearity, following example will be written in coffee, sorry for the inconveince.
Let's explain how mss translate your plain object into a css string in detail:

Rules for parsing a mss selectors
---------------------------------

+ Class selector is written in UpperCase and keep UpperCase
+ html tag selector is written in lowerCase and keep lowerCase
+ id selector is written in $UpperCase and turn into lowerCase

mss

    Slider: 
        margin: ...

    canvas: 
        margin: ...

    $Index:
        margin: ...

css

    .Slider { margin: ...}

    canvas { margin: ...}

    #index { margin: ...}

+ `$` used to write pesudo-class selector:

mss

    SliderBtn:
        padding: ...
        $hover:
            color: ...

css

    .SliderBtn { padding: ... }
    .SliderBtn:hover { color: ... }

+ `_` turn selector into a list of selectors, and you can nest list

mss

    BlueBird_BlueOcean:
        color: \blue
        RedText_$RedWine_Span:
            color: \red

css

    .BlueBird, 
    .BlueOcean {
        color: blue;
    }
    .BlueBird .RedText, 
    .BlueBird #redWine,
    .BlueBird span,
    .BlueOcean .RedText, 
    .BlueOcean #redWine,
    .BlueOcean span { 
        color: red;
    }

Rules for parsing a mss property name
-------------------------------------

+ turn `camelCase` to `camel-case` and `MyCamelCase` to `-my-camel-case`

mss

    FooBar:
        marginLeft: \50%
        MozBoxShadow: '10px 10px 5px #888888'

css

    .FooBar {
        margin-left: 50%;
        -moz-box-shadow: 10px 10px 5px #888888;
    }

Functions and Mixins
--------------------

Here comes the fun part, since the plain mss object you write is actual a simplified CSS AST, so all mixins can be write in plain javascript.


Functions
---------

Since all property are strings, we can write a function to help us convert between numbers and string, for example:


mss

    px = (x) -> x + 'px' 
    pc = (x) -> x + '%'

    $OhMyGod:
        margin: px 2
        padding: pc 10

css

    #ohMyGod {
        margin: 2px 4px 5px;
        padding 10% 10%;
    }
 
There's lots of functions are built-in in MSS, they are written in camelCase, such as `px` or `hsl`, and they are much general, for example the built-in `px` function can take multiple arguments, here's list:

```coffee
    num           # num('2px') == 2
    unit          # unit('2%') == '%'
    px            # px(1, 2, 3) == '1px, 2px, 3px'
    pc            # pc(1, 2, 3) == '1%, 2%, 3%'
    
    gold          # px(v) == Math.round(v*0.618), golden ratio caculator
    goldR         # px(v) == Math.round(v/0.618), golden ratio caculator 2

    rgb           # rgb(0, 128, 255) == 'rgb(0,128,255)'
    rgba          # rgba(0, 128, 255, 0.2) == 'rgba(0,128,255,0.2)'
    bw            # bw(128) == 'rgb(128,128,128)'
    hsl           # same as rgb, h: 0~360, s: 0~100, l: 0~100
    hsla          # same as rgb, h: 0~360, s: 0~100, l: 0~100 a: 0.0~1.0
```

Mixins
------

Mixins are special functions, they should take some parameters(or none), then return a function that modify mss object, let's write one:

mss

    Center$ = (mss) ->
        mss.textAlign = 'center'
        mss

    Padding = (pad) -> (mss) ->
        mss.padding = pad
        mss


    input: Center$ Padding('2px')
        margin: 0

css

    input{
        margin: 0;
        padding: '2px';
        text-align: 'center';
    }

Built-in mixins:

```coffee
Vendor
Mixin
Size
PosAbs
PosRel

LineSize
TouchScroll

TextEllip$
ClearFix$
```

Other functions
---------------

You can define other functions to achieve more powerful effect, there're some built-in functions written in UPPER_CASE can be used in some advanced situations.


Applications
------------

The online compiler's page's style is powered by mss(written in coffeescript), here is the source code:

```coffee
s = mss

html_body: s.Size('100%', '100%')
    overflow: 'hidden'
    fontSize: '14px'
$I: s.PosRel(0, 0) s.Size('100%', '100%')
    background: '#eee'
    Doc: s.PosAbs(0, '50%', 0 , 0)  s.Size('46%', '100%')
        padding: '2%'
        overflow: 'scroll'

    LiveParser: s.PosAbs(0, 0, 0, '50%') s.Size('46%', '96%')
        padding: '2%'
        MssInput_MssOutput:
            border: '1px solid #ccc'
            background: '#fff'
            fontSize: '1em'
        MssInput: s.Size('100%', '44%')
            background: '#F5F2F0'
        ParseHint: s.Size('100%', '2%')
            padding: '2%'
        MssOutput: s.Size('100%', '44%')
            background: '#F5F2F0'

```

The compiled CSS is directly inserted into DOM:

```css
html,
body {
    overflow: hidden;
    font-size: 14px;
    width: 100%;
    height: 100%;
}
#i {
    background: #eee;
    width: 100%;
    height: 100%;
    position: relative;
    top: 0;
    right: 0;
}
#i .Doc {
    padding: 2%;
    overflow: scroll;
    width: 46%;
    height: 100%;
    position: absolute;
    top: 0;
    right: 50%;
    bottom: 0;
    left: 0;
}
#i .LiveParser {
    padding: 2%;
    width: 46%;
    height: 96%;
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 50%;
}
#i .LiveParser .MssInput,
#i .LiveParser .MssOutput {
    border: 1px solid #ccc;
    background: #fff;
    font-size: 1em;
}
#i .LiveParser .MssInput {
    background: #F5F2F0;
    width: 100%;
    height: 44%;
}
#i .LiveParser .ParseHint {
    padding: 2%;
    width: 100%;
    height: 2%;
}
#i .LiveParser .MssOutput {
    background: #F5F2F0;
    width: 100%;
    height: 44%;
}
```

If you don't mind too much verbose here's javascript version:
```javascript
var s = mss;

html_body: s.Size('100%', '100%')({
    overflow: 'hidden',
    fontSize: '14px'
}),
$I: s.PosRel(0, 0)(s.Size('100%', '100%')({
    background: '#eee',
    Doc: s.PosAbs(0, '50%', 0, 0)(s.Size('46%', '100%')({
      padding: '2%',
      overflow: 'scroll'
    })),
    LiveParser: s.PosAbs(0, 0, 0, '50%')(s.Size('46%', '96%')({
        padding: '2%',
        MssInput_MssOutput: {
            border: '1px solid #ccc',
            background: '#fff',
            fontSize: '1em'
        },
        MssInput: s.Size('100%', '44%')({
            background: '#F5F2F0'
        }),
        ParseHint: s.Size('100%', '2%')({
            padding: '2%'
        }),
        MssOutput: s.Size('100%', '44%')({
            background: '#F5F2F0'
        })
    }))
}))

```
