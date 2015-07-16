## mss: messed up style sheet

Write CSS in a functional way with [coffeescript](http://coffeescript.org)

See [Document and online compiler](http://winterland1989.github.io/mss)

### How does mss look like?

The online compiler's page's style is powered by mss, here is the source code:

```ls
i.mss = let @ = MSS
    # define some helper mixins
    FullSize$ = @SizePc 100 100
    HalfWrapper$ = ( @SizePc 46 96 ) . ( @Mixin padding: @pc 2 2 )

    Html_Body: FullSize$ <| { overflow: \hidden }

    $I: @RelPos! <| FullSize$ <| do
        background: \#eee
        doc: @AbsPos \TL 0 0 <| HalfWrapper$ <| do
            overflow: \scroll

        liveParser: @AbsPosPc \TL 0 50 <| HalfWrapper$ <| do

            mssInput: @Border 1 \#ddd <| @SizePc 100 45 <| do
                background: \#F5F2F0

            parseHint: @CenterT$ <| @SizePc 100 2 <| { padding: @pc 2}

            mssOutput: @Border 1 \#ddd <| @SizePc 100 45 <| do
                background: \#F5F2F0


i.styleTag = MSS.tag MSS.parse i.mss
```

The compiled CSS is directly inserted into DOM:

```css
 html,
 body{
  overflow:hidden;
  width:100%;
  height:100%;
}
 #i .doc{
  overflow:scroll;
  padding:2% 2%;
  width:46%;
  height:96%;
  position:absolute;
  top:0;
  left:0;
}
 #i .liveParser .mssInput{
  background:#F5F2F0;
  width:100%;
  height:45%;
  border:1px solid #ddd;
}
 #i .liveParser .parseHint{
  padding:2%;
  width:100%;
  height:2%;
  text-align:center;
}
 #i .liveParser .mssOutput{
  background:#F5F2F0;
  width:100%;
  height:45%;
  border:1px solid #ddd;
}
 #i .liveParser{
  padding:2% 2%;
  width:46%;
  height:96%;
  position:absolute;
  top:0;
  left:50%;
}
 #i{
  background:#eee;
  width:100%;
  height:100%;
  position:relative;
  top:0;
  left:0;
}

```
