Blocks vs HybridLists
=====================

Blocks and HybridLists (and indeed all Primitive List/ish types) are pretty similar,
but there's a few imporant differences in usage.

Given
-----

We'll use this below, but its not really important.

~~~

def some_operation [
  obj [
    operation: "some"
    result:    "success"
  ]
]

~~~

Block
-----

Code blocks are a container around a set of statements.
For the purposes of metaprogramming, its internals can be accessed using standard List/ish addressing methods.

~~~

my_block: [
  first:  1
  second: 2
  third:  3
  some_operation
]

my_block[1]     ;;=> <Pair first:1>
my_block[first] ;;=> <Number 1>

my_block[4]     ;;=> <Word some_operation> ;; ie the word itself

my_block.call   ;;=> <Object operation:"some" result:"success">
                ;; ie the return value of executing some_operation
                ;; because this is the last statement in the block
                ;; however, all statements were evaluated

def my_block_function a_block [
  def some_operation [
    obj [
      operation: "none"
      result:    "failure"
    ]
  ]

  my_block[4]     ;;=> <Word some_operation>
  my_block.call   ;;=> <Object operation:"none" result:"failure">
                  ;; Evaluates block in current context
]

~~~

HybridList
----------

A HybridList is just a List that has both positional and Pair (key/value) elements.

Every element can be addressed positionally the same as normal Lists.
Elements that are key value Pairs can be addressed by key name just like Dictionaries.

~~~

my_list: (first:1 second:2 third:3 some_operation)

my_list[1]     ;;=> <Pair first:1>
my_list[first] ;;=> <Number 1>

my_list[4]     ;;=> <Object operation:"some" result:"success">
               ;; ie the return value of executing some_operation

my_list.call   ;;=> (first:1 second:2 third:3 <Object operation:"some" result:"success">)
               ;; ie the evaluated version of itself

def my_list_function a_list [
  def some_operation [
    obj [
      operation: "none"
      result:    "failure"
    ]
  ]

  my_list[4]     ;;=> <Object operation:"some" result:"success">
  my_list.call   ;;=> (first:1 second:2 third:3 <Object operation:"none" result:"failure">)
                 ;; (Re)evaluates list in current context
]

~~~

All Lists, HybridLists, and Dictionaries
---------

- Treated as a collection of entities.
- Elements are lazily evaluated, implicitly when needed.
- Elements are evaluated in the context they were defined in by default.
- When called, they return a copy of themseves with all elements evaluated.

Block Differences
----

vs lists

- Treated as a single entity.
- Only evaluated when explicitly called.
- Evaluated in the current context unless otherwise specified.
- When called, they return the result of evaluating their last statement.

Function Differences
--------

vs blocks

- Evaluated implicitly when directly referenced.

Caveats
-------

### Usage of Barewords

- I'm using barewords for key addressing, this may change in the future depending on usage.
- There's some fuzziness in my head about what you should get back from barewords in a block as well.

### Implicit Evaluation in Lists

- When/where Lists are implicitly evaluated may change based on intuitive behaviour and optimizations.
- I think Lists should be evaluated when passed in as part of method parameters or return values.
- Depending how elements are added, they may already be evaluated when they are added.
- A List's defining-context may be GC'd, but they should be evaluated first.

## Functions

- Functions are blocks.
- The only difference is that the context evaluates them when referenced.
- Functions can be captured as values and then they work just like blocks.
- Functions defined on an object operate in that object's context.

