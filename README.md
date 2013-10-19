oLua - Lua in more objective way
====

goals:
 
 - make Lua more objective (polymorphism, inheritance, encapsulation, abstraction) with respect of lua syntax (like "self", or ":")
 
 - no global variables (so I can avoid so many mistakes I used to do) - only class definitions can be global
 
 - validation (since there is no static typing in lua, runtime validation is all you can get) - validation of method's arguments and result
 
 - more validations (I still don't know what I mean by that)

check https://github.com/un1q/oLua/wiki for details


Known Issues
============

This is very first version of oLua, so don't expect to much. Actually I made it for my own purpose, so this is not well documented rough and it might doesn't work at all.

For sure:
 - enums validation is broken
 - encapsulation is not provided
 - abstraction is not provided
