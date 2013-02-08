Outer
=====

`Outer` in Hyperluminal refers to the object encapsulating the current object.

A simple example:

```
some_object: Object.subtype do
  other_object: Object.subtype do
  end
end
```

The `some_object` is `other_object`'s `outer` object. An object can only have a single `outer` object.

The `other_object` is `some_object`'s `inner` object. An object may have multiple `inner` objects.

This paradigm is particularly useful for [Object Oriented User Interface programming](http://en.wikipedia.org/wiki/NewtonScript#NewtonScript_vs._Self), 
allowing each object to "own" and handle interaction with a visual widget or window.
However, its useful for many types of heirachical development, allowing the developer to logically
structure and nest their objects as to best reveal their [intent](http://xunitpatterns.com/Intent%20Revealing%20Name.html).

The example files here model the behaviour of a simple hypothetical UI and should be functionally equivalent.

