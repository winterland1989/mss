MSS = require 'libs/MSS'
h = require 'libs/helper'
window.MSS = MSS

i = {}
i.controller = ->

i.docHTML = '<h1>Loading...</h1>'
i.parseHint = 'Please type your mss ^^^'

i.mssInput = ''
i.mssOutput = ''

marked.setOptions do
    highlight: (code) -> hljs.highlightAuto(code).value

m.request do
    url: \MSS.md
    method: \GET
    deserialize: (data) -> marked data

.then (html) -> i.docHTML = html

i.view = ->
    m '#i',
        m '.doc', m.trust i.docHTML

        m '.liveParser',
            m 'textarea.mssInput',
                value: i.mssInput
                onkeydown: (e) ->
                    # 9 => TABKEY
                    | e.keyCode == 9
                        e.preventDefault!
                        (h.eElem e).value += '    '

                        m.redraw.strategy \none

                onkeyup: (e) ->
                    i.mssInput = (h.eElem e).value
                    srcLs = 'window.mssInputObj = \n' + ((i.mssInput.split \\n).map (line) -> "    #line").join \\n
                    LiveScript.stab srcLs, (err) ->
                        if err
                            lineNumberRegex = /line (\d+)\:/
                            errMsg = err.toString!
                            errMsg = errMsg.replace lineNumberRegex, (matched, digits) ->
                                'line ' + ((parseInt digits) - 1) + \:

                            i.parseHint = errMsg

                        else i.parseHint = 'Look NICE!'
                    console.log window.mssInputObj
                    if typeof window.mssInputObj == "object"

                        i.mssOutput = MSS.parse window.mssInputObj, true

            m '.parseHint', i.parseHint

            m 'textarea.mssOutput',
                disabled: true
                value: i.mssOutput

m.module document.body, i

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


MSS.tag \i, MSS.parse i.mss

module.export = i

