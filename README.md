oLua - Lua in more objective way
====

This little thing is the library I made for purpose of my other project. My goals are:
 
 - make Lua more objective (polymorphism, inheritance, encapsulation, abstraction, with respect of lua suntax, like "self", or ":")
 
 - no global variables (so I can avoid so many mistakes I used to do - only class definitions can be global)
 
 - validation (I love static typing, but I don't want to go upstream; I want to add validation of method's arguments and result)
 
 - more validations (I still don't know what I mean by that)

Known Issues
============

This is very first version of oLua, so don't expect to much. Actually I made it for my own purpose, so this is not well documented rough and it might doesn't work at all.

For sure:
 - enums validation is broken
 - polymorphism is not provided for validation
 - encapsulation is not provided at all
 - abstraction is not provided at all
