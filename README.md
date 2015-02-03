## MSS: Messed up Style Sheet
Write CSS in a functional way with [LiveScript](http://livescript.net), Inspired by [Clay CSS compiler](http://fvisser.nl/clay/)

### Warm up
If you are familiar with [LiveScript](http://livescript.net), you can skip this section.

#### !, do and <|
`!` in LiveScript means apply a function with no argmenuts, `do` means you want pass a plain object to function, and `<|` stand for back-pipe(borrowed from F#, aka. $ in Haskell), it mean apply the right value to the left function, you can think `<|` put a () to the right expression, eg(LiveScript => Javascript):
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
### How does MSS work?

MSS.parse reveive a mss object to output a css string，a mss object is an object tree, a key will be a CSS selector if the value is another mss object, otherwise it will be property name for CSS, the nested selectors will be concated into a descendant selector（with `&` exception borrowed from stylus）, Let's see an example:
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

//will generate following CSS
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

Rules for parsing a mss selectors are:

+ lowerCaseSelector => .lowerCaseSelector
+ UpperCaseSelector => UpperCaseSelector
