# Object Literals
# ---------------

# TODO: refactor object literal tests
# TODO: add indexing and method invocation tests: {a}['a'] is a, {a}.a()

trailingComma = {k1: "v1", k2: 4, k3: (-> true),}
ok trailingComma.k3() and (trailingComma.k2 is 4) and (trailingComma.k1 is "v1")

ok {a: (num) -> num is 10 }.a 10

moe = {
  name:  'Moe'
  greet: (salutation) ->
    salutation + " " + @name
  hello: ->
    @['greet'] "Hello"
  10: 'number'
}
ok moe.hello() is "Hello Moe"
ok moe[10] is 'number'
moe.hello = ->
  this['greet'] "Hello"
ok moe.hello() is 'Hello Moe'

obj = {
  is:     -> yes,
  'not':  -> no,
}
ok obj.is()
ok not obj.not()

### Top-level object literal... ###
obj: 1
### ...doesn't break things. ###

# Object literals should be able to include keywords.
obj = {class: 'höt'}
obj.function = 'dog'
ok obj.class + obj.function is 'hötdog'

# Implicit objects as part of chained calls.
pluck = (x) -> x.a
eq 100, pluck pluck pluck a: a: a: 100


test "YAML-style object literals", ->
  obj =
    a: 1
    b: 2
  eq 1, obj.a
  eq 2, obj.b

  config =
    development:
      server: 'localhost'
      timeout: 10

    production:
      server: 'dreamboat'
      timeout: 1000

  ok config.development.server  is 'localhost'
  ok config.production.server   is 'dreamboat'
  ok config.development.timeout is 10
  ok config.production.timeout  is 1000

obj =
  a: 1,
  b: 2,
ok obj.a is 1
ok obj.b is 2

# Implicit objects nesting.
obj =
  options:
    value: yes
  fn: ->
    {}
    null
ok obj.options.value is yes
ok obj.fn() is null

# Implicit objects with wacky indentation:
obj =
  'reverse': (obj) ->
    Array.prototype.reverse.call obj
  abc: ->
    @reverse(
      @reverse @reverse ['a', 'b', 'c'].reverse()
    )
  one: [1, 2,
    a: 'b'
  3, 4]
  red:
    orange:
          yellow:
                  green: 'blue'
    indigo: 'violet'
  misdent: [[],
  [],
                  [],
      []]
ok obj.abc().join(' ') is 'a b c'
ok obj.one.length is 5
ok obj.one[4] is 4
ok obj.one[2].a is 'b'
ok (key for key of obj.red).length is 2
ok obj.red.orange.yellow.green is 'blue'
ok obj.red.indigo is 'violet'
ok obj.misdent.toString() is ',,,'

#542: Objects leading expression statement should be parenthesized.
{f: -> ok yes }.f() + 1

# String-keyed objects shouldn't suppress newlines.
one =
  '>!': 3
six: -> 10
ok not one.six

# Shorthand objects with property references.
obj =
  ### comment one ###
  ### comment two ###
  one: 1
  two: 2
  object: -> {@one, @two}
  list:   -> [@one, @two]
result = obj.object()
eq result.one, 1
eq result.two, 2
eq result.two, obj.list()[1]

third = (a, b, c) -> c
obj =
  one: 'one'
  two: third 'one', 'two', 'three'
ok obj.one is 'one'
ok obj.two is 'three'

test "invoking functions with implicit object literals", ->
  generateGetter = (prop) -> (obj) -> obj[prop]
  getA = generateGetter 'a'
  getArgs = -> arguments
  a = b = 30

  result = getA
    a: 10
  eq 10, result

  result = getA
    "a": 20
  eq 20, result

  result = getA a,
    b:1
  eq undefined, result

  result = getA b:1,
  a:43
  eq 43, result

  result = getA b:1,
    a:62
  eq undefined, result

  result = getA
    b:1
    a
  eq undefined, result

  result = getA
    a:
      b:2
    b:1
  eq 2, result.b

  result = getArgs
    a:1
    b
    c:1
  ok result.length is 3
  ok result[2].c is 1

  result = getA b: 13, a: 42, 2
  eq 42, result

  result = getArgs a:1, (1 + 1)
  ok result[1] is 2

  result = getArgs a:1, b
  ok result.length is 2
  ok result[1] is 30

  result = getArgs a:1, b, b:1, a
  ok result.length is 4
  ok result[2].b is 1

  throws -> CoffeeScript.compile "a = b:1, c"

test "some weird indentation in YAML-style object literals", ->
  two = (a, b) -> b
  obj = then two 1,
    1: 1
    a:
      b: ->
        fn c,
          d: e
    f: 1
  eq 1, obj[1]

test "#1274: `{} = a()` compiles to `false` instead of `a()`", ->
  a = false
  fn = -> a = true
  {} = fn()
  ok a

test "#1436: `for` etc. work as normal property names", ->
  obj = {}
  eq no, obj.hasOwnProperty 'for'
  obj.for = 'foo' of obj
  eq yes, obj.hasOwnProperty 'for'

test "#2706, Un-bracketed object as argument causes inconsistent behavior", ->
  foo = (x, y) -> y
  bar = baz: yes

  eq yes, foo x: 1, bar.baz

test "#2608, Allow inline objects in arguments to be followed by more arguments", ->
  foo = (x, y) -> y

  eq yes, foo x: 1, y: 2, yes

test "#2308, a: b = c:1", ->
  foo = a: b = c: yes
  eq b.c, yes
  eq foo.a.c, yes

test "#2317, a: b c: 1", ->
  foo = (x) -> x
  bar = a: foo c: yes
  eq bar.a.c, yes

test "#1896, a: func b, {c: d}", ->
  first = (x) -> x
  second = (x, y) -> y
  third = (x, y, z) -> z

  one = 1
  two = 2
  three = 3
  four = 4

  foo = a: second one, {c: two}
  eq foo.a.c, two

  bar = a: second one, c: two
  eq bar.a.c, two

  baz = a: second one, {c: two}, e: first first h: three
  eq baz.a.c, two

  qux = a: third one, {c: two}, e: first first h: three
  eq qux.a.e.h, three

  quux = a: third one, {c: two}, e: first(three), h: four
  eq quux.a.e, three
  eq quux.a.h, four

  corge = a: third one, {c: two}, e: second three, h: four
  eq corge.a.e.h, four

test "Implicit objects, functions and arrays", ->
  first  = (x) -> x
  second = (x, y) -> y

  foo = [
    1
    one: 1
    two: 2
    three: 3
    more:
      four: 4
      five: 5, six: 6
    2, 3, 4
    5]
  eq foo[2], 2
  eq foo[1].more.six, 6

  bar = [
    1
    first first first second 1,
      one: 1, twoandthree: twoandthree: two: 2, three: 3
      2,
    2
    one: 1
    two: 2
    three: first second ->
      no
    , ->
      3
    3
    4]
  eq bar[2], 2
  eq bar[1].twoandthree.twoandthree.two, 2
  eq bar[3].three(), 3
  eq bar[4], 3

test "#2549, Brace-less Object Literal as a Second Operand on a New Line", ->
  foo = no or
    one: 1
    two: 2
    three: 3
  eq foo.one, 1

  bar = yes and one: 1
  eq bar.one, 1

  baz = null ?
    one: 1
    two: 2
  eq baz.two, 2

test "#2757, Nested", ->
  foo =
    bar:
      one: 1,
  eq foo.bar.one, 1

  baz =
    qux:
      one: 1,
    corge:
      two: 2,
      three: three: three: 3,
    xyzzy:
      thud:
        four:
          four: 4,
      five: 5,

  eq baz.qux.one, 1
  eq baz.corge.three.three.three, 3
  eq baz.xyzzy.thud.four.four, 4
  eq baz.xyzzy.five, 5

test "#1865, syntax regression 1.1.3", ->
  foo = (x, y) -> y

  bar = a: foo (->),
    c: yes
  eq bar.a.c, yes

  baz = a: foo (->), c: yes
  eq baz.a.c, yes


test "#1322: implicit call against implicit object with block comments", ->
  ((obj, arg) ->
    eq obj.x * obj.y, 6
    ok not arg
  )
    ###
    x
    ###
    x: 2
    ### y ###
    y: 3

test "#1513: Top level bare objs need to be wrapped in parens for unary and existence ops", ->
  doesNotThrow -> CoffeeScript.run "{}?", bare: true
  doesNotThrow -> CoffeeScript.run "{}.a++", bare: true

test "#1871: Special case for IMPLICIT_END in the middle of an implicit object", ->
  result = 'result'
  ident = (x) -> x

  result = ident one: 1 if false

  eq result, 'result'

  result = ident
    one: 1
    two: 2 for i in [1..3]

  eq result.two.join(' '), '2 2 2'

test "#1871: implicit object closed by IMPLICIT_END in implicit returns", ->
  ob = do ->
    a: 1 if no
  eq ob, undefined

  # instead these return an object
  func = ->
    key:
      i for i in [1, 2, 3]

  eq func().key.join(' '), '1 2 3'

  func = ->
    key: (i for i in [1, 2, 3])

  eq func().key.join(' '), '1 2 3'

test "#1961, #1974, regression with compound assigning to an implicit object", ->

  obj = null

  obj ?=
    one: 1
    two: 2

  eq obj.two, 2

  obj = null

  obj or=
    three: 3
    four: 4

  eq obj.four, 4

test "#2207: Immediate implicit closes don't close implicit objects", ->
  func = ->
    key: for i in [1, 2, 3] then i

  eq func().key.join(' '), '1 2 3'

test "#3216: For loop declaration as a value of an implicit object", ->
  test = [0..2]
  ob =
    a: for v, i in test then i
    b: for v, i in test then i
    c: for v in test by 1 then v
    d: for v in test when true then v
  arrayEq ob.a, test
  arrayEq ob.b, test
  arrayEq ob.c, test
  arrayEq ob.d, test

test 'inline implicit object literals within multiline implicit object literals', ->
  x =
    a: aa: 0
    b: 0
  eq 0, x.b
  eq 0, x.a.aa

test "object keys with interpolations", ->
  # Simple cases.
  a = 'a'
  obj = "#{a}": yes
  eq obj.a, yes
  obj = {"#{a}": yes}
  eq obj.a, yes
  obj = {"#{a}"}
  eq obj.a, 'a'
  obj = {"#{5}"}
  eq obj[5], '5' # Note that the value is a string, just like the key.

  # Commas in implicit object.
  obj = "#{'a'}": 1, b: 2
  deepEqual obj, {a: 1, b: 2}
  obj = a: 1, "#{'b'}": 2
  deepEqual obj, {a: 1, b: 2}
  obj = "#{'a'}": 1, "#{'b'}": 2
  deepEqual obj, {a: 1, b: 2}

  # Commas in explicit object.
  obj = {"#{'a'}": 1, b: 2}
  deepEqual obj, {a: 1, b: 2}
  obj = {a: 1, "#{'b'}": 2}
  deepEqual obj, {a: 1, b: 2}
  obj = {"#{'a'}": 1, "#{'b'}": 2}
  deepEqual obj, {a: 1, b: 2}

  # Commas after key with interpolation.
  obj = {"#{'a'}": yes,}
  eq obj.a, yes
  obj = {
    "#{'a'}": 1,
    "#{'b'}": 2,
    ### herecomment ###
    "#{'c'}": 3,
  }
  deepEqual obj, {a: 1, b: 2, c: 3}
  obj =
    "#{'a'}": 1,
    "#{'b'}": 2,
    ### herecomment ###
    "#{'c'}": 3,
  deepEqual obj, {a: 1, b: 2, c: 3}
  obj =
    "#{'a'}": 1,
    "#{'b'}": 2,
    ### herecomment ###
    "#{'c'}": 3, "#{'d'}": 4,
  deepEqual obj, {a: 1, b: 2, c: 3, d: 4}

  # Key with interpolation mixed with `@prop`.
  deepEqual (-> {@a, "#{'b'}": 2}).call(a: 1), {a: 1, b: 2}

  # Evaluate only once.
  count = 0
  b = -> count++; 'b'
  obj = {"#{b()}"}
  eq obj.b, 'b'
  eq count, 1

  # Evaluation order.
  arr = []
  obj =
    a: arr.push 1
    b: arr.push 2
    "#{'c'}": arr.push 3
    "#{'d'}": arr.push 4
    e: arr.push 5
    "#{'f'}": arr.push 6
    g: arr.push 7
  arrayEq arr, [1..7]
  deepEqual obj, {a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7}

  # Object starting with dynamic key.
  obj =
    "#{'a'}": 1
    b: 2
  deepEqual obj, {a: 1, b: 2}

  # Comments in implicit object.
  obj =
    ### leading comment ###
    "#{'a'}": 1

    ### middle ###

    "#{'b'}": 2
    # regular comment
    'c': 3
    ### foo ###
    d: 4
    "#{'e'}": 5
  deepEqual obj, {a: 1, b: 2, c: 3, d: 4, e: 5}

  # Comments in explicit object.
  obj = {
    ### leading comment ###
    "#{'a'}": 1

    ### middle ###

    "#{'b'}": 2
    # regular comment
    'c': 3
    ### foo ###
    d: 4
    "#{'e'}": 5
  }
  deepEqual obj, {a: 1, b: 2, c: 3, d: 4, e: 5}

  # A more complicated case.
  obj = {
    "#{'interpolated'}":
      """
        #{ '''nested''' }
      """: 123: 456
  }
  deepEqual obj,
    interpolated:
      nested:
        123: 456

test "#4324: Shorthand after interpolated key", ->
  a = 2
  obj = {"#{1}": 1, a}
  eq 1, obj[1]
  eq 2, obj.a

test "#1263: Braceless object return", ->
  fn = ->
    return
      a: 1
      b: 2
      c: -> 3

  obj = fn()
  eq 1, obj.a
  eq 2, obj.b
  eq 3, obj.c()
