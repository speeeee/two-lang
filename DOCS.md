Documentation
====

# Syntax

two-lang's syntax, at its base, is very simple.  There are only a few rules to keep track of, and they are explained in the following sections.

## Basics

Here is a simple integer input into the REPL:

```
1
```

The output is as follows:

```
((1 Int))
```

There are multiple interesting things about this.  First, `1` has a type associated with it.  Types wil be explained in more detail later, focus just on the `1` for now.  Another thing is that the output produces a *list* of the integer, `1`.