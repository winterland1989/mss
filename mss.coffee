#########################################      #   #    ########
# helper to add style to browser ########    # # # #    ########
#########################################  #   #   #    ########

# load a css string to DOM(with id is optional), return the style element
tag = (cssText, id) ->
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

# reload a css string to a style element
reTag = (cssText, styleEl) ->
    if isIeLessThan9
        styleEl.styleSheet.cssText = cssText
    else
        styleEl.childNodes[0].textContent = cssText
    styleEl

# unload a style element from DOM
unTag = (styleEl) ->
    if styleEl then document.head.removeChild styleEl

# check IE version
isIeLessThan9 = ->
    div = document.createElement 'div'
    div.innerHTML = "<!--[if lt IE 9]><i></i><![endif]-->"
    div.getElementsByTagName("i").length == 1

#########################################      #   #    ########
# let's rock ############################    # # # #    ########
#########################################  #   #   #    ########

# recursive parser
parseR = (selectors, mss, indent, lineEnd) ->
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
                newSelectors =
                    [ "#{sel}#{subSel}" for sel in selectors for subSel in subSelectors ]
                subCssRule += parseR newSelectors, val, indent, lineEnd
            else
                cssRule += "#{indent}#{parsePropName key}:#{val};#{lineEnd}"

    (if cssRule != ''
        "#{selectors.join ',' + lineEnd}{#{lineEnd}#{cssRule}}#{lineEnd}"
    else '') + subCssRule

# parse a mss object into raw css string
parse = (mss, pretty = false) ->
    indent = parseR [''], mss, (if pretty then '  ' else ''), (if pretty then '\n' else '')

# selector parsing rules (* stand for space):
# &fooBar -> continue parse fooBar    => continue parse and directly concated with parent selector
# fooBar  -> *.fooBar                   => class selector
# FooBar  -> *fooBar                    => html tags
# $fooBar -> :fooBar                    => shorthand pesudo class/element
# $FooBar -> *#fooBar                   => id selector
parseSelectors = (selectorString) ->
    selectors = selectorString.split '_'
    for sel in selectors
        nest = ' '
        if (firstChar = sel[0]) == '&'                         # direct concat selector
            sel = sel.slice 1
            nest = ''
        switch true
            when firstChar == '$'
                if 'a' <= sel[1] <= 'z'                             # $hover -> :hover
                    ':' + sel.slice 1
                else if 'A' <= sel[1] <= 'Z'
                    nest + '#' + sel[1].toLowerCase() + sel.slice 2    # $FooBar -> #fooBar
            when 'A' <= firstChar <= 'Z'                              # Foobar -> ' .Foobar'
                nest + '.' + sel
            when 'a' <= firstChar <= 'z'                              # img -> ' img'
                nest + firstChar.toLowerCase() + sel.slice 1
            else                                                      # do nothing if dont recognize
                nest + sel

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

# background image
bgi = (imgURL, position = CENTER, repeat = 'no-repeat', attachment, clip) ->
    "url(#imgURL) position repeat" +
    (if attachment then attachment else '') +
    (if clip then clip else '')

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

# css3 gradient functions
# linear gradient
linearGrad = (sideOrAngle, stops) ->
    "linear-gradient(#sideOrAngle,#{stops.join ','})"

# radial gradient
radialGrad = (stops) ->
    "radial-gradient(#{stops.join ','})"

# repeat gradient
repeatGrad = (sideOrAngle, stops) ->
    "repeat-gradient(#sideOrAngle,#{stops.join ','})"

#########################################      #   #    ########
# method start with UpperCase -> mixins      # # # #    ########
#########################################  #   #   #    ########

# aka overload, didnt serve as a base function for performance concerns
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

###
# transistion shorthand with default value
# type cant be :
#
# @param prop {String}
# @param time {String}
# @param type {String}
# @param delay {String}
# @return {mss}
###
Transit = (prop, time, type = 'ease', delay = '0s') -> (mss) ->
    mss.transition = "#prop #time #type #delay"
    mss

# inline block with float extension and ie fix
InlineBlock = (directions = 'left') -> (mss) ->
    mss.display = 'inline-block'
    mss.float = directions
    mss['*zoom'] = 1
    mss['*display'] = 'inline'
    mss

# vertical align a line
LineSize = (lineHeight, fontS) -> (mss) ->
    mss.verticalAlign = 'middle'
    if lineHeight?
        mss.height = mss.lineHeight = lineHeight
    if fontS?
        mss.fontSize = fontS
    mss

# set hover color with cursor to pointer
HoverBtn = ( textcolor, bgcolor, cur = 'pointer' ) -> (mss) ->
    unless mss.$hover? then mss.$hover = {}
    mss.$hover.cursor = cur
    if textcolor then mss.$hover.color = textcolor
    if bgcolor then mss.$hover.background = bgcolor
    mss

# vendor prefix a prop
Vendor = (prop) -> (mss) ->
    if (v = mss[prop])?
        PropBase = prop[0].toUpperCase() + prop.slice 1
        mss[ 'Moz' + PropBase ]    = v
        mss[ 'Webkit' + PropBase ] = v
        mss[ 'Ms' + PropBase ]     = v
    mss

# css3 animate
Animate = (name, time, type = 'linear', delay = '0s', iter = 1, direction, fill, state) -> (mss) ->
    mss.animate = "#{name} #{time} #{type} #{delay} #{iter}" +
        (if direction? then direction else '') +
        (if fill? then fill else '') +
        (if state? then state else '')
    mss

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
# UPPERCASE -> BOMBs, use with CAUTIONs!     # # # #    ########
#########################################  #   #   #    ########


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
#
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

module.exports =
    parse:             parse
    tag:               tag
    parseSelectors:    parseSelectors
    parsePropName:     parsePropName


