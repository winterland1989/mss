#########################################      #   #    ########
#-jsm-keywords: style DSL        ########    # # # #    ########
#########################################  #   #   #    ########

#########################################      #   #    ########
# helper to add style to browser ########    # # # #    ########
#########################################  #   #   #    ########

###
# load a css string to DOM(with id is optional), return the style element
#
# @param mss {mssObject}
# @param id {String}
# @return {DOMNode}
###
tag = (mss, id) ->
    cssText = parse mss
    styleEl = document.createElement 'style'
    if id then styleEl.id = id
    styleEl.type = 'text/css'
    # Fix IE < 9
    if isIeLessThan9
        styleEl.appendChild document.createTextNode(cssText)
    else
        styleEl.styleSheet.cssText = cssText

    #Append style element to head
    document.head = document.head || document.getElementsByTagName('head')[0]
    document.head.appendChild styleEl
    styleEl

###
# reload a css string to a style element
#
# @param mss {mssObject}
# @param styeEl {DOMNode}
# @return {DOMNode}
###
reTag = (mss, styleEl) ->
    cssText = parse mss
    if isIeLessThan9
        styleEl.childNodes[0].textContent = cssText
    else
        styleEl.styleSheet.cssText = cssText
    styleEl

###
# unload a style element from DOM
#
# @param styleEl {DOMNode}
# @return {undefined}
###
unTag = (styleEl) ->
    if styleEl then document.head.removeChild styleEl

###
# check IE version
#
# @return {Boolean}
###
isIeLessThan9 = ->
    div = document.createElement 'div'
    div.innerHTML = "<!--[if lt IE 9]><i></i><![endif]-->"
    div.getElementsByTagName("i").length == 1

#########################################      #   #    ########
# let's rock ############################    # # # #    ########
#########################################  #   #   #    ########

###
# recursive parser
#
# @param selectors {[String]}
# @param mss {mssObj}
# @param indent {'    ' | '  ' | ''}
# @param lineEnd {'\n' | ''}
# @return {String}
###
parseR = (selectors, mss, indent, lineEnd) ->

    # merge mss if was an Array
    if mss instanceof Array
        mergedMss = {}
        for mssObj in mss
            for k, v of mssObj
                mergedMss[k] = v
        mss = mergedMss

    cssRule = ''
    subCssRule = ''
    newSelectors = undefined
    for key, val of mss
        # preserve @rules
        if key[0] == '@'
            # @rules for @media, @keyframes..
            if typeof val is "object"
                subCssRule += "#{key}{#{lineEnd}#{parseR [''], val, indent, lineEnd}}#{lineEnd}"
            # @rules for @charset, @import..
            else subCssRule += "#{key} #{val};#{lineEnd}"
        else
            # expand sub mss objects
            if typeof val is "object"
                # for the spirit of list monad, let's expand!
                subSelectors = parseSelectors key
                newSelectors = do ->
                    res = []
                    res.push "#{sel}#{subSel}" for sel in selectors for subSel in subSelectors
                    res
                subCssRule += parseR(newSelectors, val, indent, lineEnd)
            else if val?
                cssRule += "#{indent}#{parsePropName key}:#{val};#{lineEnd}"

    (if cssRule != ''
        "#{selectors.join ',' + lineEnd}{#{lineEnd}#{cssRule}}#{lineEnd}"
    else '') + subCssRule

###
# parse a mss object into raw css string
#
# @param mss {mssObject}
# @param pretty {Boolean} default = false
# @return {String}
###
parse = (mss, pretty = false) ->
    indent = parseR [''], mss, (if pretty then '  ' else ''), (if pretty then '\n' else '')

# selector parsing rules (* stand for space):
# FooBar  -> *.FooBar                   => class selector
# $FooBar -> #fooBar                    => id selector
# $hover -> :hover                      => shorthand pesudo class/element
# fooBar  -> *fooBar                    => html tags, custom selector

parseSelectors = (selectorString) ->
    selectors = selectorString.split '_'
    for sel in selectors
        if 'A' <= sel[0] <= 'Z' then ' .' + sel
        else if sel[0] == '$'
            if 'A' <= sel[1] <= 'Z' then ' #' + sel[1].toLowerCase() + sel[2..]
            else ':' + sel[1..]
        else ' ' + sel

# prop name parsing rules:
# marginLeft -> margin-left
# MozBorderRadius -> -moz-border-radius

parsePropName = (prop) ->
    transformed = ''
    for c in prop
        if  'A' <= c <= 'Z'
            transformed += "-" + c.toLowerCase()
        else
            transformed += c
    transformed

#########################################      #   #    ########
# method start with lowerCase -> functions   # # # #    ########
#########################################  #   #   #    ########

# 34px -> 34
num = parseInt

# 34px -> px, 43% -> %
unit = (str) ->
    switch str[-1..]
        when '%' then '%'
        else str.slice -2

# (1, 2, 3) -> '1px 2px 3px'
px = ->
    s = ''
    i = 0
    argsN = arguments.length - 1
    while i < argsN
        s += arguments[i++] + 'px '
    s += arguments[i] + 'px'
    s

# (10, 20, 30) -> '1% 2% 3%'
pc = ->
    s = ''
    i = 0
    argsN = arguments.length - 1
    while i < argsN
        s += arguments[i++] + '% '
    s += arguments[i] + '%'
    s

# golden ratio calculator
gold = (v) -> Math.round v*0.618
goldR = (v) -> Math.round v/0.618

# rgb color
rgb = (r, g, b) -> "rgb(#{r},#{g},#{b})"

# BW color
bw = (bw) -> "rgb(#{bw},#{bw},#{bw})"

# rgba color
rgba = (r, g, b, a) -> "rgba(#{r},#{g},#{b},#{a})"

# hsl color, hue: 0~360, saturation: 0~100, lightness: 0~100
hsl = (h, s, l) -> "hsl(#{h},#{s}%,#{l}%)"

# hsla color, hue: 0~360, saturation: 0~100, lightness: 0~100, alpha: 0.0~1.0
hsla = (r, g, b, a) -> "hsla(#{h},#{s}%,#{l}%,#{a})"


#########################################      #   #    ########
# method start with UpperCase -> mixins      # # # #    ########
#########################################  #   #   #    ########

# vendor prefix a prop
Vendor = (prop) -> (mss) ->
    if (v = mss[prop])?
        PropBase = prop[0].toUpperCase() + prop.slice 1
        mss[ 'Moz' + PropBase ]    = v
        mss[ 'Webkit' + PropBase ] = v
        mss[ 'Ms' + PropBase ]     = v
    mss

# didnt serve as a base function for performance concerns
Mixin = (mssMix) -> (mss) ->
    for k, v of mssMix
        mss[k] = v
    mss

# size shorthand
Size = (width, height) -> (mss) ->
    if width? then mss.width = width
    if height? then mss.height = height
    mss

# absolute position
PosAbs = (top, right, bottom, left) -> (mss) ->
    mss.position = 'absolute'
    if top?    then mss.top = top
    if right?  then mss.right = right
    if bottom? then mss.bottom = bottom
    if left?   then mss.left = left
    mss

PosRel = (top, right, bottom, left) -> (mss) ->
    mss.position = 'relative'
    if top?    then mss.top = top
    if right?  then mss.right = right
    if bottom? then mss.bottom = bottom
    if left?   then mss.left = left
    mss

# vertical align a line, set height, lineHeight and fontSize at the same time
LineSize = (lineHeight, fontS) -> (mss) ->
    if lineHeight?
        mss.height = mss.lineHeight = lineHeight
    if fontS?
        mss.fontSize = fontS
    mss

# wrap a mss object into a MEDIA query, example:
# MediaQuery
#   all:
#     maxWidth: '1200px'
#   _handheld:
#     minWidth: '700px'
#   $tv:
#     color: void
#
# ...

MediaQuery = (queryObj) -> (mss) ->
    queryStrArr = for mediaType, queryRules of queryObj
        if mediaType[0] == '_' then mediaType = 'not ' + mediaType.slice 1
        if mediaType[0] == '$' then mediaType = 'only ' + mediaType.slice 1
        if queryRules
            mediaType + ' and ' +
            (for k, v of queryRules
                '(' + (parsePropName k) +
                (if v then ':' + v else '') + ')'
            ).join ' and '
        else mediaType
    "@media #{queryStrArr.join ','}": mss

# better normalized KeyFrames
KeyFrames = (name) -> (mss) ->
    keyFramesObj = {}
    max = 0
    for k of mss
        max = Math.max max, Number.parseFloat k
    for k, v of mss
        keyFramesObj[ (Number.parseFloat k)*100/max + '%' ] = v

    "@keyframes #{name}": keyFramesObj

#########################################      #   #    ########
# mixins end with $ dont need arguments #    # # # #    ########
#########################################  #   #   #    ########

# Ellipsis text
TextEllip$ = (mss) ->
    mss.whiteSpace = 'nowrap'
    mss.overflow = 'hidden'
    mss.textOverflow = 'ellipsis'
    mss

# clearFix
ClearFix$ = (mss) ->
    mss['*zoom'] = 1
    mss.$before_$after =
        content: "''"
        display: 'table'
    mss.$after =
        clear: 'both'
    mss

#########################################      #   #    ########
# UPPERCASE ->        use with CAUTIONs!     # # # #    ########
#########################################  #   #   #    ########

TRAVERSE = (mss, mssFn = ((k,v) -> v), propFn = ((k,v) -> v)) ->
    newMss = {}
    for k, v of mss
        newMss[k] =
            if typeof v is 'object'
                TRAVERSE((mssFn k, v), mssFn, propFn)
            else propFn(k, v)
    newMss

mss = {
    tag
    reTag
    unTag

    parse
    parseSelectors
    parsePropName

    num
    unit
    px
    pc

    gold
    goldR

    rgb
    bw
    rgba
    hsl
    hsla

    Vendor
    Mixin
    Size
    PosAbs
    PosRel
    LineSize

    MediaQuery
    KeyFrames

    TextEllip$
    ClearFix$

    TRAVERSE
}

if module? and  module.exports?
    module.exports = mss
else if (typeof define == "function" and define.amd)
    define -> mss
else if window?
    window.mss = mss
