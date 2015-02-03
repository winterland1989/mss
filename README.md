## MSS: Messed up Style Sheet
Write CSS in a functional way with [LiveScript](http://livescript.net), Inspired by [Clay CSS compiler](http://fvisser.nl/clay/)

### How does MSS work?

MSS.parse takes a mss object as input and output a css string

+ A mss object is an plain javascript object, usually nested
+ A key will be a CSS selector if its value is another mss object, otherwise it will be take as a property name for CSS
+ MSS will parse the nested object into nested selectors by connnecting selectors into a descendant selector

Let's see an example:
```
mss =
    fooClass:
        zIndex: 999
        $BarId_anotherClass:
            MozBoxShadow: '10px 10px 5px #888888'
            Input:
                borderRadius: '12px'
                padding: '12px'
                width: '100%'   
                
MSS.parse mss, true
// set second argmument to true to enable prettify , parse above mss will generate following CSS
.fooClass #barId input,
.fooClass .anotherClass input{
  border-radius:12px;
  padding:12px;
  width:100%;
}
.fooClass #barId,
.fooClass .anotherClass{
  -moz-box-shadow:10px 10px 5px #888888;
}
.fooClass{
  z-index:999;
}
```
As shown above, the selectors and prop name are converted for the writing  ease in LiveScript(using valid variable as much as possible) 

**Rules for parsing a mss selectors are:**

+ Class selector is written in lowerCase
+ html tag selector is written in UpperCase
+ id selector is written in $UpperCase, eg(mss => CSS):
```
slider: 
    margin: ...
=> 
.slider { margin: ...}

Canvas: 
    margin: ...
=>
canvas { margin: ...}

$Index: 
    margin: ...
=> 
#index { margin: ...}
```
+ nested selectors is concated with space, while `&` cancel it
```
slider:
    margin: ... 
    sliderBtn:
        padding: ...
    &on:
        color: ...
=> 
.slider { margin: ... }
.slider .sliderBtn {padding: ...} 
.slider.on {color: ...}
```
+ `$` cancel the descendant space and connect parent selector with `:`
```
sliderBtn:
    padding: ...
    $hover:
        color: ...
=>
.sliderBtn { padding: ... }
.sliderBtn:hover { color: ... }
```
+ `_` turn selector into a list of selectors, and you can nest list
```
blueBird_blueOcean:
    color: \blue
    redText_$RedWine_Span:
        color: \red
=>
.blueBird, 
.blueOcean {
    color: blue;
}
.blueBird .redText, 
.blueBird #redWine,
.blueBird span,
.blueOcean .redText, 
.blueOcean #redWine,
.blueOcean span { 
    color: red;
}

```
**Rules for parsing a mss prop-name are:**
+ turn `camelCase` to `camel-case` and `MyCamelCase` to `-my-camel-case`
```
fooBar:
    marginLeft: \50%
    MozBoxShadow: '10px 10px 5px #888888'
=>
.fooBar {
    margin-left: 50%;
    -moz-box-shadow: 10px 10px 5px #888888;
}
```
### Functions and Mixins
Here comes the fun part, you should know some basic LiveScript syntax, such as `\` create a string literal, `let` create a lambda call, and we will use `!`, `do` and `<|` a lot.
#### Warm up, !, do and <|
If you are familiar with [LiveScript](http://livescript.net), you can skip this section.
`!` in LiveScript means apply a function with no arguments, `do` means pass a plain object to a function, and `<|` stand for back-pipe(borrowed from F#, aka. $ in Haskell), it mean apply the right value to the left function, you can think `<|` as it put right expression into a invisible`()`, eg(LiveScript => Javascript):
```
foo = (bar = 8) -> console.log bar
foo! 
# will log 8
foobar do
    a: 1
    b: {c:2}

foo = (x) -> (y) -> console.log x + y
foo 2 <| 3
# will log 5
```
=>
```
var foo;
foo = function(bar){
  bar == null && (bar = 8);
  return console.log(bar);
};
foo();
//console will log 8

foobar({
  a: 1,
  b: {
    c: 2
  }
});

var foo;
foo = function(x){
  return function(y){
    return console.log(x + y);
  };
};
foo(2)(3);
//console will log 5
```

#### Helper Functions
Helper functions are quite easy, they are just like function you used in stylus, all helper functions in MSS is written in camelCase, such as `px` or `rgba`
```
$OhMyGod:
    margin: MSS.px 2 4 5
    padding: MSS.pc 10 10
=>
#LiveScript Object in VM
$OhMyGod:
    margin: '2px 4px 5px'
    padding: '10% 10%'
=>
#ohMyGod {
    margin: 2px 4px 5px;
    padding 10% 10%;
}
```
See Full List of helper functions provided by MSS [HERE](https://github.com/winterland1989/MSS/blob/master/MSS.ls#L90)

#### Mixins
Mixins are special functions, they should take a mss object as argument and return a decorated(modified) mss object, usually Mixins need take more arguments to know how to decorate the mss object, so there're two kinds of Mixins:

+ All Mixins are written in MyCamelCase
+ Mixins that dont need extra arguments are end with `$` such as `CenterT$` which simply add `text-align: center` to a mss object
+ Mixins that need extra arguments are curried functions(need append `!` to use default arguments) such as `Border`
+ Since Mixins are just functions with type signature :: mss -> mss, you can add more Mixins by connecting them with `<|`
+ use `do` after the last `<|` to pass orginal mss object into Mixins or add a `{}` if don't have one

```
OhMyGod: MSS.Border 5 \red \LR <| MSS.CenterT$ <| do
    margin: ...
=>
#LiveScript Object in VM
ohMyGod:
    borderLeft: '5px solid red'
    borderRight: '5px solid red'
    textAlign: 'center'
=>
.ohMyGod {
    border-left: '5px solid red'
    border-right: '5px solid red'
    text-align: 'center'
}

```
See Full List of Mixins provided by MSS [HERE](https://github.com/winterland1989/MSS/blob/master/MSS.ls#L120)

#### BOMBS
At this point i guess you wanna ask, can we do something more fun/functional? After all, we are using programming language to write a plain text document, so here we go, let's see a MAP_SUFFIX BOMB in action:

+ BOMBS are written in UPPER_CASE, use with CAUTION!
+ MSS.MAP_SUFFIX :: (list_of_suffix, indexMixin) -> (mss) -> mss
    +  list_of_suffix is suffix list concated with `_` just like in mss
    + indexMixin :: (suffix, index) -> (mss) -> mss

```
ohMyGoooood: MSS.MAP_SUFFIX \Night_Morning_Dying,
    (suffix, index) -> (mss) -> mss
        ..$after = content: \'+ suffix + \'
        ..top = MSS.px index*200
<|  do
    Fuck:
        color: \red
=>
ohMyGoooood:
    FuckNight:
        color: \red
        $after:
            content: \'Night'
        top: \0px
    FuckMorning:
        color: \red
        $after':
            content: \'Morning'
        top: \200px
    FuckDying:
        color: \red
        $after:
            content: \'Dying'
        top: \400px
=>
.ohMyGoooood .FuckNight {
    color: red;
    top: 0px;
}
.ohMyGoooood .FuckNight:after{
    content: 'Night';
}
.ohMyGoooood .FuckMorning {
    color: red;
    top: 200px;
}
.ohMyGoooood .FuckMorning:after{
    content: 'Morning';
}
.ohMyGoooood .FuckDying {
    color: red;
    top: 400px;
}
.ohMyGoooood .FuckDying:after{
    content: 'Dying';
}
```
See Full List of BOMBS provided by MSS [HERE](https://github.com/winterland1989/MSS/blob/master/MSS.ls#L247)

### Usage 
I used MSS inside browser without hassels, More Mixins, functions and BOMBS are W.I.P
