## mss: messed up style sheet

Write CSS in a functional way with javascript.

See [Document and online compiler](http://winterland1989.github.io/mss).

### How does mss look like?

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
