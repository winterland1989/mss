s = window.mss

docHTML = '<h1>Loading...</h1>'
parseHint = 'Please type your mss ^^^'

mssInput = ''
mssOutput = ''

marked.setOptions highlight: (code) ->
    hljs.highlightAuto(code).value

m.request(
  url: 'README.md.html'
  method: 'GET'
  deserialize: (data) ->
    marked data
).then (html) ->
    docHTML = html

m.module document.body, view: ->
    m '#i'
    ,   m '.doc', m.trust(docHTML)
    ,   m '.liveParser'
        ,   m 'textarea.mssInput' ,
                value: mssInput
                onkeydown: (e) ->
                    if e.keyCode != 9
                        e.preventDefault()
                        self = h.eElem(e)
                        selStart = self.selectionStart
                        self.value = self.value.substring(0, selStart) + '    ' + self.value.substring(selStart)
                        self.selectionStart = self.selectionEnd = selStart + 4
                        m.redraw.strategy('none')

                onkeyup: (e) ->
                    srcLs = undefined
                    mssInput = h.eElem(e).value
                    srcLs = 'window.mssInputObj = \n' + mssInput

                    CoffeeScript.eval srcLs, (err) ->
                        if err
                            lineNumberRegex = /line (\d+)\:/
                            errMsg = err.toString()
                            errMsg = errMsg.replace(lineNumberRegex, (matched, digits) ->
                                'line ' + parseInt(digits) - 1 + ':'
                            )
                            parseHint = errMsg
                        else if typeof window.mssInputObj == 'object'
                            parseHint = 'Look NICE!'
                            mssOutput = s.parse(window.mssInputObj, true)

            ,   m '.parseHint', parseHint
            ,   m 'textarea.mssOutput',
                    disabled: true
                    value: mssOutput

FullSize$ = s.Size('100%', '100%')
HalfWidth$ = s.Size('100%', '50%')

s.tag
    html_body: s.Size('100%', '100%')
        overflow: 'hidden'
    $I: s.RelPos() s.Size('100%', '100%')
        background: '#eee'
        doc: s.AbsPos(0, '50%', 0 , 0) HalfWidth$
            overflow: 'scroll'

        liveParser: s.AbsPosPc(0, 0, 0, '50%') HalfWidth$
            mssInput: s.SizePc(100, 45)
                background: '#F5F2F0'
            parseHint: s.Size('100%', '2%')
                padding: '2%'
            mssOutput: s.SizePc(100, 45)
                background: '#F5F2F0'
