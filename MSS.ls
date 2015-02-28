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

# parse a mss object into raw css string
MSS.parse = (mss, pretty = false, compiledStylePrefix = '') ->
    compiledStyle = compiledStylePrefix
    lineEnd = if pretty then \\n else ''
    indentSpace = if pretty then '  ' else ''
    # recursive parser
    parseR = (selectors, mss) ->
        cssRule = ''
        mssArrFlag = mss instanceof Array
        for key, val of mss
            # preserve @rules, abandon previous selectors
            if key.0 == \@
                # @rules for @media, @keyframes..
                if typeof val is "object"
                    compiledStyle := compiledStyle + key + \{ + lineEnd
                    parseR [''], val
                    compiledStyle := compiledStyle + \} + lineEnd
                # @rules for @charset, @import..
                else compiledStyle := compiledStyle + key + ' ' + val + \\n
            else
                # expand sub mss objects
                if typeof val is "object"
                    subSelectors = key.split '_'
                    subSelectors = MSS.parseSelectors subSelectors
                    # abandon array index
                    if mssArrFlag then newSelectors = selectors
                    # for the spirit of list monad, let's expand!
                    else newSelectors =
                        [ "#sel#subSel" for sel in selectors for subSel in subSelectors ]
                    parseR newSelectors, val
                else
                    cssRule += indentSpace + (MSS.parsePropName key) + ":#val;" + lineEnd

        if cssRule.length
            compiledStyle := compiledStyle + ( selectors.join ",#lineEnd" ) +
                \{ + lineEnd + "#cssRule" + \} + lineEnd

    parseR [''], mss
    compiledStyle

# selector parsing rules (* stand for space):
# &fooBar -> continue parse fooBar    => continue parse and directly concated with parent selector
# fooBar  -> *.fooBar                   => class selector
# FooBar  -> *fooBar                    => html tags
# $fooBar -> :fooBar                    => shorthand pesudo class/element
# $FooBar -> *#fooBar                   => id selector
MSS.parseSelectors = (selectors) ->
    selectors.map (sel) ->
        nest = ' '
        # direct concat selector
        if sel.0 == \&
            sel = sel.slice 1
            nest = ''
        switch
        # $hover -> :hover
        | sel.0 == \$ and \a <= sel.1 <= \z then ':' + sel.slice 1
        # $FooBar -> #fooBar
        | sel.0 == \$ and \A <= sel.1 <= \Z then nest + \# + sel.1.toLowerCase! + sel.slice 2
        # foobar -> \ .foobar
        | \a <= sel.0 <= \z                 then nest + \. + sel
        # Img -> \ img
        | \A <= sel.0 <= \Z                 then nest + sel.0.toLowerCase! + sel.slice 1
        # do nothing if dont recognize
        | otherwise                         then sel

# prop name parsing rules:
# marginLeft -> margin-left
# MozBorderRadius -> -moz-border-radius
MSS.parsePropName = (prop) ->
    transformed = ''
    i = 0
    while (c = prop.[i])?
        if  'A' <= c <= 'Z'
            transformed += "-" + c.toLowerCase!
        else
            transformed += c
        i++
    transformed

#########################################      #   #    ########
# method start with lowerCase -> functions   # # # #    ########
#########################################  #   #   #    ########

# (1, 2, 3) -> '1px 2px 3px'
MSS.px = (...vArr) -> (vArr.join 'px ') + \px

# (10, 20, 30) -> '1% 2% 3%'
MSS.pc = (...vArr) -> (vArr.join '% ') + \%

# golden ratio calculator
MSS.gold = (v) -> Math.round v*0.618
MSS.goldR = (v) -> Math.round v/0.618

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
# a helper to mix color and position
MSS.mixStops = (colorStops, posStops, unit) ->
    posStops.map (pos, index) -> colorStops[index] = colorStops[index] + ' ' + pos + unit
    colorStops.join \,

# linear gradient
MSS.lnrGrad = (sideOrAngle, colorStops = [], posStops = []) ->
    c = MSS.mixStops colorStops, posStops, \px
    "linear-gradient(#sideOrAngle,#c)"

MSS.lnrGradPc = (sideOrAngle, colorStops, posStops) ->
    c = MSS.mixStops colorStops, posStops, \%
    "linear-gradient(#sideOrAngle,#c)"

# radial gradient
MSS.radGrad = (colorStops, posStops) ->
    c = MSS.mixStops colorStops, posStops, \px
    "radial-gradient(#c)"

MSS.radGradPc = (colorStops, posStops) ->
    c = MSS.mixStops colorStops, posStops, \%
    "radial-gradient(#c)"

# repeat gradient
MSS.rptGrad = (sideOrAngle, colorStops, posStops) ->
    c = MSS.mixStops colorStops, posStops, \px
    "repeat-gradient(#sideOrAngle,#c)"

MSS.rptGradPc = (sideOrAngle, colorStops, posStops) ->
    c = MSS.mixStops colorStops, posStops, \%
    "repeat-gradient(#sideOrAngle,#c)"

#########################################      #   #    ########
# method start with UpperCase -> mixins      # # # #    ########
#########################################  #   #   #    ########

# aka overload, didnt serve as a base function for performance concerns
MSS.Mixin = (mssMix) -> (mss) -> mss <<<< mssMix

# a helper for directional css property de-shorthand, eg margin, padding...
MSS.DirectionVal = (directions, props, vArr, unit, propsDirections = [\Top \Right \Bottom \Left]) -> (mss) -> mss
    <[T R B L]>.map (dir, index) ->
        if (i = directions.indexOf dir) != -1
            ..[ props + propsDirections[index] ] = if v = vArr[i] then v + unit else 0

# size shorthand
MSS.Size = (width, height) -> (mss) -> mss
    if width then ..width = width + \px
    if height then ..height = height + \px

MSS.SizePc = (width, height) -> (mss) -> mss
    if width then ..width = width + \%
    if height then ..height = height + \%

# margin shorthand
MSS.Mar = (directions = '', ...v) ->
    MSS.DirectionVal directions, \margin, v, \px

MSS.MarPc = (directions = '', ...v) ->
    MSS.DirectionVal directions, \margin, v, \%

MSS.AMar = (...v) -> (mss) -> mss
    ..margin = MSS.px ...v

MSS.AMarPc = (...v) -> (mss) -> mss
    ..margin = MSS.pc ...v

# padding shorthand
MSS.Pad = (directions = '', ...v) ->
    MSS.DirectionVal directions, \padding, v, \px

MSS.PadPc = (directions = '', ...v) ->
    MSS.DirectionVal directions, \padding, v, \%

MSS.APad = (...v) -> (mss) -> mss
    ..padding = MSS.px ...v

MSS.APadPc = (...v) -> (mss) -> mss
    ..padding = MSS.pc ...v

# border shorthand
MSS.Border = (directions = '', width = 1, color = \#eee, borderStyle = \solid) ->
    style = "#{width}px #borderStyle #color"
    v = [style, style, style, style]
    MSS.DirectionVal directions, \border, v, ''

MSS.ABorder =  (width = 0, color = \#eee, borderStyle = \solid) -> (mss) -> mss
    ..border = "#{width}px #borderStyle #color"

# border radius
MSS.BorderRadius = (directions = '', ...v) -> (mss) ->
    mss |>
    MSS.DirectionVal directions, \border, v, \px, [\TopLeftRadius \TopRightRadius \BottomLeftRadius \TopLeftRadius] |>
    MSS.DirectionVal directions, \border, v, \px, [\TopRightRadius \BottomRightRadius \BottomRightRadius \BottomLeftRadius]

MSS.BorderRadiusPc = (directions = '', ...v) -> (mss) ->
    mss |>
    MSS.DirectionVal directions, \border, v, \%, [\TopLeftRadius \TopRightRadius \BottomLeftRadius \TopLeftRadius] |>
    MSS.DirectionVal directions, \border, v, \%, [\TopRightRadius \BottomRightRadius \BottomRightRadius \BottomLeftRadius]

MSS.ABorderRadius = (...v) -> (mss) -> mss
    ..borderRadius = MSS.px ...v

MSS.ABorderRadiusPc = (...v) -> (mss) -> mss
    ..borderRadius = MSS.pc ...v

# corner radius
MSS.CornerRadius = (corner = '', ...v) -> (mss) ->
    cornerAlias = []
    if corner.indexOf(\TL) != -1 or corner.indexOf(\LT) != -1 then cornerAlias.push \T
    if corner.indexOf(\TR) != -1 or corner.indexOf(\RT) != -1 then cornerAlias.push \R
    if corner.indexOf(\RB) != -1 or corner.indexOf(\BR) != -1 then cornerAlias.push \B
    if corner.indexOf(\BL) != -1 or corner.indexOf(\LB) != -1 then cornerAlias.push \L
    mss |>
    MSS.DirectionVal cornerAlias, \border, v, \px, [\TopLeftRadius \TopRightRadius \BottomRightRadius \BottomLeftRadius]

MSS.CornerRadiusPc = (corner = '', ...v) -> (mss) ->
    cornerAlias = []
    if corner.indexOf(\TL) != -1 or corner.indexOf(\LT) != -1 then cornerAlias.push \T
    if corner.indexOf(\TR) != -1 or corner.indexOf(\RT) != -1 then cornerAlias.push \R
    if corner.indexOf(\RB) != -1 or corner.indexOf(\BR) != -1 then cornerAlias.push \B
    if corner.indexOf(\BL) != -1 or corner.indexOf(\LB) != -1 then cornerAlias.push \L
    mss |>
    MSS.DirectionVal cornerAlias, \border, v, \%, [\TopLeftRadius \TopRightRadius \BottomRightRadius \BottomLeftRadius]

# absolute position
MSS.AbsPos = (directions = '', ...v) -> (mss) -> mss
    ..position = \absolute
    MSS.DirectionVal directions, '', v, \px, [\top, \right, \bottom, \left]  <| mss

MSS.AbsPosPc = (directions = '', ...v) -> (mss) -> mss
    ..position = \absolute
    MSS.DirectionVal directions, '', v, \%, [\top, \right, \bottom, \left]  <| mss

# relative position
MSS.RelPos = (directions = '', ...v) -> (mss) -> mss
    ..position = \relative
    MSS.DirectionVal directions, '', v, \px, [\top, \right, \bottom, \left]  <| mss

MSS.RelPosPc = (directions = '', ...v) -> (mss) -> mss
    ..position = \relative
    MSS.DirectionVal directions, '', v, \%, [\top, \right, \bottom, \left]  <| mss

# transistion shorthand with default value
MSS.Tran = (prop = '', time = 0.2, type = \ease, delay = 0) -> (mss) -> mss
    ..transition = "#prop #{time}s #type #{delay}s"

MSS.TranMs = (prop = '', time = 0.2, type = \ease, delay = 0) -> (mss) -> mss
    ..transition = "#prop #{time}ms #type #{delay}ms"

# inline block with float extension and ie fix
MSS.InlineB = (directions = void) -> (mss) -> mss
    ..display = \inline-block
    switch
    | directions == \L => ..float = \left
    | directions == \R => ..float = \right
    if directions
        ..[\*zoom] = 1
        ..[\*display] = \inline

# float shorthand
MSS.Float = (directions = void) -> (mss) -> mss
    switch
    | directions == \L => ..float = \left
    | directions == \R => ..float = \right

# vertical align a line
MSS.LineH = (h, fontS) -> (mss) -> mss
    if h
        ..height = h + \px
        ..lineHeight = h + \px
    if fontS
        ..fontSize = fontS + \px
    ..verticalAlign = \middle

MSS.LineHPc = (h, fontS) -> (mss) -> mss
    if h
        ..height = h + \%
        ..lineHeight = h + \%
    if fontS
        ..fontSize = fontS + \%
    ..verticalAlign = \middle

# set hover color with cursor to pointer
MSS.Hover = ( color, cur = \pointer ) -> (mss) -> mss
    ..{}$hover.cursor = cur
    if color then ..$hover.color = color

# vendor prefix a prop
MSS.Vendor = (propName) -> (mss) -> mss
    if (v = ..[propName])?
        PropBase = propName.0.toUpperCase! + propName.slice 1
        ..[ \Moz + PropBase ]    = v
        ..[ \Webkit + PropBase ] = v
        ..[ \Ms + PropBase ]     = v

# css border arrow
MSS.Arrow = (directions, width, color) -> (mss) ->
    if directions.indexOf(\T) != -1
        MSS.Border width, color, \B <| MSS.Border width, \transparent, \TLR <| mss
    if directions.indexOf(\R) != -1
        MSS.Border width, color, \L <| MSS.Border width, \transparent, \TRB <| mss
    if directions.indexOf(\B) != -1
        MSS.Border width, color, \T <| MSS.Border width, \transparent, \LRB <| mss
    if directions.indexOf(\L) != -1
        MSS.Border width, color, \R <| MSS.Border width, \transparent, \TLB <| mss

# css3 animate
MSS.Animate = (name, time = 1, type = \linear, delay = 0, iter = 1,  direction = \normal, fill = \none, state = \running) ->
    (mss) -> mss
        ..animate = "#name #{time}s #type #{delay}ms #iter #direction #fill #state"

MSS.AnimateMs = (name, time = 1, type = \linear, delay = 0, iter = 1,  direction = \normal, fill = \none, state = \running) ->
    (mss) -> mss
        ..animate = "#name #{time}ms #type #{delay}ms #iter #direction #fill #state"

#########################################      #   #    ########
# mixins end with $ dont need arguments #    # # # #    ########
#########################################  #   #   #    ########

# center a block
MSS.CenterB$ = (mss) -> mss
    ..margin = '0 auto'

# center text inline elemnt inside
MSS.CenterT$ = (mss) -> mss
    ..textAlign = \center

# center wrapper using margin = 0 auto, top = 50%
MSS.CenterWrap$ = (mss) -> mss
    ..position = \relative
    ..top = \50%
    ..margin = '0 auto'
    ..height = 0

# Ellipsis text
MSS.EllipT$ = (mss) -> mss
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
