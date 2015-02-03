################################################################
# Project: m system ## Author: winter####      #   #    ########
# My mysterious monolithic monster ---->>    # # # #    ########
# File Desc: my style sheet  ▽ ▽ ▽ ▽ ▽ ▽   #   #   #    ########
################################################################

MSS = {}

#########################################      #   #    ########
# helper to add style to browser ########    # # # #    ########
#########################################  #   #   #    ########

MSS.tag = (id, cssText) ->
    styleEl = document.createElement('style')
    styleEl.id = id
    #Apparently some version of Safari needs the following line? I dunno.
    if !window.ltIE9
        styleEl.appendChild document.createTextNode(cssText)
    #Append style element to head
    document.head = document.head || document.getElementsByTagName('head')[0]
    document.head.appendChild styleEl

#########################################      #   #    ########
# let's rock ############################    # # # #    ########
#########################################  #   #   #    ########

# parse a mss object into raw css string
MSS.parse = (mss, pretty = false, compiledStylePrefix = '') ->
    compiledStyle = compiledStylePrefix
    lineEnd = if pretty then \\n else ''
    indentSpace = if pretty then '  ' else ''

    parseR = (selectors, mss) ->
        cssRule = ''
        for key of mss
            if typeof mss[key] is "object"
                subSelectors = key.split '_'
                subSelectors = MSS.parseSelectors subSelectors
                # for the spirit of list monad!
                newSelectors =
                    [ "#sel#subSel" for sel in selectors for subSel in subSelectors ]
                parseR newSelectors, mss[key]
            else
                cssRule += indentSpace + (MSS.parsePropName key) + ":#{mss[key]};" + lineEnd

        if cssRule.length then compiledStyle := compiledStyle +
            ( selectors.join ",#lineEnd" )+
            '{' + lineEnd + "#cssRule" + '}' + lineEnd
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
        | otherwise                         then nest + sel.0.toLowerCase! + sel.slice 1

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
MSS.rgb = (r, g, b) -> "rgba(#r,#g,#b)"

# rgba color
MSS.rgba = (r, g, b, a) -> "rgba(#r,#g,#b,#a)"

# hsl color, hue: 0~360, saturation: 0~100, lightness: 0~100
MSS.hsl = (h, s, l) -> "hsl(#h,#s%,#l%)"

# hsla color, hue: 0~360, saturation: 0~100, lightness: 0~100, alpha: 0.0~1.0
MSS.hsla = (r, g, b, a) -> "hsla(#h,#s%,#l%,#a)"

# array value helper
MSS.arrValU = (vArr, i, unit) ->
    if v = vArr[i] then v + unit else 0

#########################################      #   #    ########
# method start with UpperCase -> mixins      # # # #    ########
#########################################  #   #   #    ########

# size shorthand
MSS.Size = (width, height) -> (mss) -> mss
    if width then ..width = width + \px
    if height then ..height = height + \px

MSS.SizePc = (width, height) -> (mss) -> mss
    if width then ..width = width + \%
    if height then ..height = height + \%

# border shorthand, arguments order: width, color, directions, borderStyle; example:
# (5, \red, \LR, \dashed) ->
#   borderLeft: 5px dashed red
#   borderRight: 5px dashed red
MSS.Border = (width = 0, color = \#eee, directions = \A, borderStyle = \solid) -> (mss) ->
    style = "#{width}px #borderStyle #color"
    mss
        if directions.indexOf(\A) != -1 then ..border = style
        else
            if directions.indexOf(\T) != -1 then ..borderTop    = style
            if directions.indexOf(\R) != -1 then ..borderRight  = style
            if directions.indexOf(\B) != -1 then ..borderBottom = style
            if directions.indexOf(\L) != -1 then ..borderLeft   = style

# transistion shorthand with default value
MSS.Tran = (prop = \width, time = 0.2, type = \ease, delay = 0) -> (mss) -> mss
    ..transition = "#prop #{time}s #type #{delay}s"

MSS.TranMs = (prop = \width, time = 0.2, type = \ease, delay = 0) -> (mss) -> mss
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

# position helper
MSS.Pos = (directions = '', vArr = [], unit = \px) -> (mss) -> mss
    if (i = directions.indexOf(\T)) != -1 then ..top    = MSS.arrValU vArr, i, unit
    if (i = directions.indexOf(\R)) != -1 then ..right  = MSS.arrValU vArr, i, unit
    if (i = directions.indexOf(\B)) != -1 then ..bottom = MSS.arrValU vArr, i, unit
    if (i = directions.indexOf(\L)) != -1 then ..left   = MSS.arrValU vArr, i, unit

# absolute position
MSS.AbsPos = (directions = \TL, ...v) -> (mss) -> mss
    ..position = \absolute
    MSS.Pos directions, v <| mss

MSS.AbsPosPc = (directions = \TL, ...v) -> (mss) -> mss
    ..position = \absolute
    MSS.Pos directions, v, \% <| mss

# relative position
MSS.RelPos = (directions = \TL, ...v) -> (mss) -> mss
    ..position = \relative
    MSS.Pos directions, v <| mss

MSS.RelPosPc = (directions = \TL, ...v) -> (mss) -> mss
    ..position = \relative
    MSS.Pos directions, v, \% <| mss

# vertical align a line
MSS.LineH = (h, fontS) -> (mss) -> mss
    if h
        ..height = h + \px
        ..lineHeight = h + \px
    if fontS
        ..fontSize = fontS
    ..verticalAlign = \middle

# set hover cursor to pointer
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

#########################################      #   #    ########
# UPPERCASE -> BOMBS, use with caution ##    # # # #    ########
#########################################  #   #   #    ########

# indexMixin$ :: (prefix, index) -> (mss) -> mss
# you'd better know what you are doing ^_^
MSS.PREFIX_MAP = (prefixs_, indexMixin) -> (mss) ->
    newMss = {}
    prefixs = prefixs_.split '_'
    for sel of mss
        prefixs.map (prefix, index) ->
            newMss.[prefix+sel] = {}
            newMss.[prefix+sel] <<<< (indexMixin prefix, index <| mss[sel])

    newMss

MSS.MAP_SUFFIX = (_suffix, indexMixin) -> (mss) ->
    newMss = {}
    suffixs = _suffix.split '_'
    for sel of mss
        suffixs.map (suffix, index) ->
            newMss.[sel+suffix] = {}
            newMss.[sel+suffix] <<<< (indexMixin suffix, index <| mss[sel])

    newMss

module.exports = MSS
