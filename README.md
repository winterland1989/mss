## MSS
### Write css in functional ways

This library is inspired by clay CSS compiler(haskell), while i'm looking for a better way to write CSS in front end environment (browsers js runtime). actually it's easy and expressive, so let's begin:

### Warm up
If you are familiar with [LiveScript](http://livescript.net), you can skip this section.

#### ! and do
! in LiveScript simplily means apply a function with no argmenuts, do means you want pass a plain object to function, eg(LiveScript => Javascript):
```
foo = (bar = 8) -> console.log bar
foo! 

foobar do
    a: 1
    b: {c:2}
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

```

#### <|
<| stand for pipe(borrowed from F#, aka. $ in haskell), it mean apply the right value to the left function, so here we go:
```
foo = (x) -> (y) -> console.log x + y
foo 2 <| 3
```
=>
```
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

MSS.parse reveive a mss object to output a css string:
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

In another word, a mss object is an object tree, a key will be a CSS selector if the value is another mss object, otherwise it will be property name for CSS, the nested selectors will be concated into a descendant selector, the rules for MSS selectors are:

+ lowerCaseSelector => .lowerCaseSelector
+ UpperCaseSelector => UpperCaseSelector
