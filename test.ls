require! './MSS'

t = (testName, v1, v2 ) ->
    # use livescript deep equal syntax
    if v1 === v2
        console.log "#testName passed!"
    else
        console.error "#testName failed!"
        console.log \v1
        console.log v1
        console.log \v2
        console.log v2


t do
    'parse class selector'
    ' .foo{margin:12px;}'
    MSS.parse do
        foo:
            margin: \12px

t do
    'parse tag selector'
    ' canvas{margin:12px;}'
    MSS.parse do
        Canvas:
            margin: \12px

t do
    'parse id selector'
    ' #foo{margin:12px;}'
    MSS.parse do
        $Foo:
            margin: \12px

t do
    'parse pesudo selector'
    ' .foo:hover{pointer:cursor;}'
    MSS.parse do
        foo:
            $hover:
                pointer: \cursor

t do
    'parse desendent selector'
    ' .foo .bar{margin:12px;}'
    MSS.parse do
        foo:
            bar:
                margin: \12px


t do
    'linear gradient Mixin'
    ' .foo{background:linear-gradient(T,#eee 10px,red 20px);}'
    MSS.parse do
        foo:
            background: MSS.lnrGrad \T [\#eee, \red] [10 20]



