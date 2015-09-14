assert = require 'assert'
s = require './dist/mss.js'

{log, error: err} = console
test = (desc, t) ->
    log desc
    try
        t()
        log 'PASSED'
    catch e
        err e
        err 'FAILED'


test 'keep lowercase prop name', ->
    assert.equal(
        s.parsePropName 'margin'
        'margin'
    )

test 'add - before uppercase prop name', ->
    assert.equal(
        s.parsePropName 'paddingLeft'
        'padding-left'
    )
    assert.equal(
        s.parsePropName 'MozBorderRaduis'
        '-moz-border-raduis'
    )

test 'id selector ', ->
    assert.deepEqual(
        s.parseSelectors '$Id'
        [' #id']
    )

test 'class selector ', ->
    assert.deepEqual(
        s.parseSelectors 'Class'
        [' .Class']
    )

test 'html tag selector ', ->
    assert.deepEqual(
        s.parseSelectors 'span'
        [' span']
    )

test 'pesudo selector ', ->
    assert.deepEqual(
        s.parseSelectors '$hover'
        [':hover']
    )

test 'multi selectors', ->
    assert.deepEqual(
        s.parseSelectors '$hover_$Id_Class'
        [':hover', ' #id', ' .Class']
    )

test 'simple parse', ->
    assert.deepEqual(
        s.parse
            $Foo:
                margin: '2px'
        ' #foo{margin:2px;}'
    )

test 'recursive parse', ->
    assert.deepEqual(
        s.parse
            $Foo:
                Bar:
                    padding:'2px'
                margin: '2px'
        ' #foo{margin:2px;} #foo .Bar{padding:2px;}'
    )

test 'array parse', ->
    assert.deepEqual(
        s.parse [
                $Foo:
                    color: 'red'
            ,
                Bar:
                    padding:'2px'
            ]
        ' #foo{color:red;} .Bar{padding:2px;}'
    )
