################################################################
# Project: m system ## Author: winter####      #   #    ########
# My mysterious monolithic monster ---->>    # # # #    ########
# File Desc: my style sheet  ▽ ▽ ▽ ▽ ▽ ▽   #   #   #    ########
################################################################

MSS = {}

#########################################      #   #    ########
# helper to add style to browser ########    # # # #    ########
#########################################  #   #   #    ########

# load a css string to DOM(with id is optional), return the style element
MSS.tag = (cssText, id) ->
    styleEl = document.createElement('style')
    if id then styleEl.id = id
    styleEl.type = \text/css
    # Fix IE < 9
    if !window.ltIE9
        styleEl.appendChild document.createTextNode(cssText)
    else
        styleEl.styleSheet.cssText = cssText

    #Append style element to head
    document.head = document.head || document.getElementsByTagName('head')[0]
    document.head.appendChild styleEl
    styleEl

# reload a css string to a style element
MSS.reTag = (cssText, styleEl) ->
    if !window.ltIE9
        styleEl.childNodes[0].textContent = cssText
    else
        styleEl.styleSheet.cssText = cssText
    styleEl

# unload a style element from DOM
MSS.unTag = (styleEl) ->
    if styleEl then document.head.removeChild styleEl

#########################################      #   #    ########
# let's rock ############################    # # # #    ########
#########################################  #   #   #    ########

# recursive parser
parseR = (selectors, mss, indent, lineEnd) ->
    cssRule = ''
    subCssRule = ''
    newSelectors = void
    for key, val of mss
        # preserve @rules
        if key.0 == \@
            # @rules for @media, @keyframes..
            if typeof val is "object"
                subCssRule += "#key{#lineEnd#{parseR [''], val, indent, lineEnd}}#lineEnd"
            # @rules for @charset, @import..
            else subCssRule += key + ' ' + val + \\n
        else
            # expand sub mss objects
            if typeof val is "object"
                # for the spirit of list monad, let's expand!
                subSelectors = MSS.parseSelectors key.split '_'
                newSelectors =
                    [ "#sel#subSel" for sel in selectors for subSel in subSelectors ]
                subCssRule += parseR newSelectors, val, indent, lineEnd
            else
                cssRule += "#indent#{MSS.parsePropName key}:#val;#lineEnd"

    (if cssRule != ''
        "#{selectors.join \, + lineEnd}{#lineEnd#cssRule}#lineEnd"
    else '') + subCssRule

# parse a mss object into raw css string
MSS.parse = (mss, pretty = false) ->
    indent = parseR [''], mss, (if pretty then '  ' else ''), (if pretty then \\n else '')

# selector parsing rules (* stand for space):
# &fooBar -> continue parse fooBar    => continue parse and directly concated with parent selector
# fooBar  -> *.fooBar                   => class selector
# FooBar  -> *fooBar                    => html tags
# $fooBar -> :fooBar                    => shorthand pesudo class/element
# $FooBar -> *#fooBar                   => id selector
MSS.parseSelectors = (selectors) ->
    for sel in selectors
        nest = ' '
        if (firstChar = sel.0) == \&                         # direct concat selector
            sel = sel.slice 1
            nest = ''
        switch
        | firstChar == \$
            if \A <= sel.1 <= \Z                             # $Hover -> :hover
                ':' + sel.slice 1
            else if \a <= sel.1 <= \z
                nest + \# + sel.1.toLowerCase! + sel.slice 2 # $fooBar -> #fooBar
        | \A <= firstChar <= \Z                              # Foobar -> \ .foobar
            nest + \. + sel
        | \a <= firstChar <= \z                              # img -> \ img
            nest + firstChar.toLowerCase! + sel.slice 1
        | otherwise                                          # do nothing if dont recognize
            nest + sel

# prop name parsing rules:
# marginLeft -> margin-left
# MozBorderRadius -> -moz-border-radius
MSS.parsePropName = (prop) ->
    transformed = ''
    for i from 0 til prop.length
        if  'A' <= (c = prop[i]) <= 'Z'
            transformed += "-" + c.toLowerCase!
        else
            transformed += c
    transformed

#########################################      #   #    ########
# method start with lowerCase -> functions   # # # #    ########
#########################################  #   #   #    ########

# 34px -> 34
MSS.num = window.parseInt

# 34px -> px, 43% -> %
MSS.unit = (str) ->
    switch str[*-1]
    | \% => \%
    | _ => str.slice -2

# (1, 2, 3) -> '1px 2px 3px'
MSS.px = ->
    s = ''
    i = 0
    argsN = &length - 1
    while i < argsN
        s += &[i++] + 'px '
    s += &[i] + \px
    s

# (10, 20, 30) -> '1% 2% 3%'
MSS.pc = ->
    s = ''
    i = 0
    argsN = &length - 1
    while i < argsN
        s += &[i++] + '% '
    s += &[i] + \%
    s

# golden ratio calculator
MSS.goldpx = (v) -> Math.round v*0.618 + \px
MSS.goldpc = (v) -> Math.round v*0.618 + \%
MSS.goldRpx = (v) -> Math.round v/0.618 + \px
MSS.goldRpc = (v) -> Math.round v/0.618 + \%

# background image
MSS.bgi = (imgURL, position = \center, repeat = \no-repeat, attachment, clip) ->
    "url(#imgURL) position repeat" +
    (if attachment then attachment else '') +
    (if clip then clip else '')

# rgb color
MSS.rgb = (r, g, b) -> "rgb(#r,#g,#b)"

# BW color
MSS.bw = (bw) -> "rgb(#bw,#bw,#bw)"

# rgba color
MSS.rgba = (r, g, b, a) -> "rgba(#r,#g,#b,#a)"

# hsl color, hue: 0~360, saturation: 0~100, lightness: 0~100
MSS.hsl = (h, s, l) -> "hsl(#h,#s%,#l%)"

# hsla color, hue: 0~360, saturation: 0~100, lightness: 0~100, alpha: 0.0~1.0
MSS.hsla = (r, g, b, a) -> "hsla(#h,#s%,#l%,#a)"

# css3 gradient functions
# linear gradient
MSS.linear = (sideOrAngle, stops) ->
    "linear-gradient(#sideOrAngle,#{stops.join \,})"

# radial gradient
MSS.radial = (stops) ->
    "radial-gradient(#{stops.join \,})"

# repeat gradient
MSS.repeat = (sideOrAngle, stops) ->
    "repeat-gradient(#sideOrAngle,#{stops.join \,})"

#########################################      #   #    ########
# method start with UpperCase -> mixins      # # # #    ########
#########################################  #   #   #    ########

# aka overload, didnt serve as a base function for performance concerns
MSS.Mixin = (mssMix) -> (mss) -> mss <<<< mssMix

# size shorthand
MSS.Size = (width, height) -> (mss) -> mss
    if width? then ..width = width
    if height? then ..height = height

# absolute position
MSS.PosAbs = (top, right, bottom, left) -> (mss) -> mss
    ..position = \absolute
    if top?    => ..top = top
    if right?  => ..right = right
    if bottom? => ..bottom = bottom
    if left?   => ..left = left

MSS.PosRel = (top, right, bottom, left) -> (mss) -> mss
    ..position = \relative
    if top?    => ..top = top
    if right?  => ..right = right
    if bottom? => ..bottom = bottom
    if left?   => ..left = left

# transistion shorthand with default value
MSS.Transit = (prop, time, type = \ease, delay = \0s) -> (mss) -> mss
    ..transition = "#prop #time #type #delay"

# inline block with float extension and ie fix
MSS.InlineBlock = (directions = \left) -> (mss) -> mss
    ..display = \inline-block
    ..float = directions
    ..[\*zoom] = 1
    ..[\*display] = \inline

# vertical align a line
MSS.AlignLine = (h, fontS) -> (mss) -> mss
    ..verticalAlign = \middle
    if h?
        ..height = h
        ..lineHeight = h
    if fontS?
        ..fontSize = fontS

# set hover color with cursor to pointer
MSS.HoverBtn = ( textcolor, bgcolor, cur = \pointer ) -> (mss) -> mss
    ..{}$hover.cursor = cur
    if textcolor then ..$hover.color = textcolor
    if bgcolor then ..$hover.background = bgcolor

# vendor prefix a prop
MSS.Vendor = (propName) -> (mss) -> mss
    if (v = ..[propName])?
        PropBase = propName.0.toUpperCase! + propName.slice 1
        ..[ \Moz + PropBase ]    = v
        ..[ \Webkit + PropBase ] = v
        ..[ \Ms + PropBase ]     = v

# css3 animate
MSS.Animate = (name, time, type = \linear, delay = \0ms, iter = 1, direction, fill, state) ->
    (mss) -> mss
        ..animate = "#name #time #type #delay #iter" +
            (if direction then direction else '') +
            (if fill then fill else '') +
            (if state then state else '')

#########################################      #   #    ########
# mixins end with $ dont need arguments #    # # # #    ########
#########################################  #   #   #    ########

# center text inline elemnt inside
MSS.TextCenter$ = (mss) -> mss
    ..textAlign = \center

# center wrapper using margin = 0 auto, top = 50%
MSS.CenterWrap$ = (mss) -> mss
    ..position = \relative
    ..top = \50%
    ..margin = '0 auto'
    ..height = 0

# Ellipsis text
MSS.TextEllip$ = (mss) -> mss
    ..whiteSpace = \nowrap
    ..overflow = \hidden
    ..textOverflow = \ellipsis

# clearFix
MSS.ClearFix$ = (mss) -> mss
    ..[\*zoom] = 1
    ..$before_$after =
        content: \''
        display: \table
    ..$after =
        clear: \both

#########################################      #   #    ########
# UPPERCASE -> BOMBs, use with CAUTIONs!     # # # #    ########
#########################################  #   #   #    ########

# MAP Mixin to a mss object's mss object, while preserve it's own CSS props
# Mixin :: (mss) -> mss
MSS.MAP = (Mixin) -> (mss) ->
    newMss = {}
    for key of mss
        if typeof mss[key] is "object"
            newMss[key] = Mixin mss[key]
        else
            newMss[key] = mss[key]
    newMss

# same as above, with an extra selector argument passed to Mixin
# Mixin :: (selector) -> (mss) -> mss
MSS.APPLY = (Mixin) -> (mss) ->
    newMss = {}
    for key of mss
        if typeof mss[key] is "object"
            newMss[key] = Mixin key <| mss[key]
        else
            newMss[key] = mss[key]
    newMss

# same as APPLY plus prefix and index argmument
# indexMixin$ :: (prefix, index, originSelector) -> (mss) -> mss
MSS.PREFIX_MAP = (prefixs_, indexMixin) -> (mss) ->
    newMss = {}
    prefixs = prefixs_.split '_'
    for key of mss
        if typeof mss[key] is "object"
            prefixs.map (prefix, index) ->
                newMss[prefix+key] = {}
                newMss[prefix+key] <<<< (indexMixin prefix, index, key <| mss[key])
        else
            newMss[key] = mss[key]
    newMss

# indexMixin$ :: (prefix, index, originSelector) -> (mss) -> mss
MSS.MAP_SUFFIX = (_suffix, indexMixin) -> (mss) ->
    newMss = {}
    suffixs = _suffix.split '_'
    for key of mss
        if typeof mss[key] is "object"
            suffixs.map (suffix, index) ->
                newMss[key+suffix] = {}
                newMss[key+suffix] <<<< (indexMixin suffix, index, key <| mss[key])
        else
            newMss[key] = mss[key]
    newMss

# LIFT Mixin to sub mss object, while preserve CSS props
# levelStart, which level a lifted Mixin begin to apply, default: 0
# levelEnd: which level a lifted Mixin stop to apply, default: -1
# levelEnd: any negative number resulted in deepest level of mss tree
# Mixin :: (selector) -> (mss) -> mss
MSS.LIFT = (Mixin, levelStart = 0, levelEnd = -1) -> (mss) ->
    newMss = {}
    for key of mss
        if typeof mss[key] is "object"
            if levelEnd != 0
                mss[key] = MSS.LIFT Mixin, levelStart-1, levelEnd-1 <| mss[key]

            if levelStart <= 0
                newMss[key] = Mixin key <| mss[key]
            else
                newMss[key] = mss[key]
        else
            newMss[key] = mss[key]
    newMss

# wrap a mss object into a MEDIA query, example:
# MSS.MEDIA do
#   all:
#     maxWidth: \1200px
#   _handheld:
#     minWidth: \700px
#   $tv:
#     color: void
# <|
# ...
#
MSS.MEDIA_QUERY = (queryObj) -> (mss) ->
    queryStrArr = for mediaType, queryRules of queryObj
        if mediaType[0] == \_ then mediaType = 'not ' + mediaType.slice 1
        if mediaType[0] == \$ then mediaType = 'only ' + mediaType.slice 1
        if queryRules
            mediaType + ' and ' +
            (for k, v of queryRules
                \( + (MSS.parsePropName k) +
                (if v then \: + v else '') + \)
            ).join ' and '
        else mediaType
    ('@media ' + queryStrArr.join ','): mss

# better normalized KeyFrames
MSS.KEY_FRAMES = (name) -> (mss) ->
    keyFramesObj = {}
    max = 0
    for k of mss
        max = Math.max max, Number.parseFloat k
    for k, v of mss
        keyFramesObj[ (Number.parseFloat k)*100/max + '%' ] = v

    "@keyframes #name": keyFramesObj

module.exports = MSS
