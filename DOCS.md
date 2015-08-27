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

There are multiple interesting things about this.  First, `1` has a type associated with it.  Types wil be explained in more detail later, focus just on the `1` for now.  Another thing is that the output produces a *list* of the integer, `1`.  This is the main concept of two-lang.  First, it should be noted that all two-lang programs have an empty list at the end of them:

```
1 ()
```

Between every pair of values in two-lang, there is an implied operator.  This operator does something based off of the arguments it is given.  In this case, the left argument is `1` and the right argument is `()`.  There is a rule that when the operands are a literal and a list, the result is a new list with the literal as the head and the old list as the tail.  As a result, the list created is `(1)`.  This list, `(1)`, is used to replace the expression, `1 ()`.  

Now consider this following expression:

```
2 1 ()
```

This is where it should be explained that two-lang is *right-associative*.  That is, all operations are grouped from right-to-left:

```
2 [1 ()]
```

The expression in brackets is then replaced with this:

```
2 (1)
```

The same process is applied to these two operands.  It is still a literal and a list, so the result is `(2 1)`.  This process can be chained with any number of terms.  The language takes the terms and reduces them into their simplest form.

Something to note is that the returned list, `(2 1)`, is somewhat misleading.  What is actually returned is the list, `((2 Int) (1 Int))`.  The only difference is that each literal is paired with its respective type.  This is explained in detail later.

## Rules and pattern-matching

One of the builtin symbols in two-lang is the `=` symbol.  As mentioned before, when the implied operator's left argument is a literal and its right argument a list, they construct a new list.  This is one of the only builtin rules in two-lang.  However, `=` can be used two define new rules.  Here is an example definition of a rule:

```
(+ ((1 Int) (1 Int))) = 2
```

What this means is that whenever `+ 1 1` is found, it is replaced with `2`.  This is the other major point of two-lang: the idea of pattern-matching.  When a pattern is matched, it is replaced with what the matched rule's output.  The other thing to notice is the fact that the left argument of `=` is a list of two items.  These two items are the left and right arguments for the implied operator.  What this means is that the left operand must be `+` and the right operand must be `((1 Int) (1 Int))`.  As a result, the side of a rule that is to be matched *must* contain two items.  One for the left operand and one for the right operand.

## Variables

So far, there isn't much to do other than creating aliases using rule definitions.  However, variables allow for looser pattern matching.  Recall that all literals are automatically paired with their respective type.  Sometimes, it is desirable to isolate the literal for when the type itself is not needed.

```
(lit (($a Int))) = $a
```

The above example does that.  It isolates the literal value from the type.  In this rule, there is an odd symbol, `$a`.  This, and any other string prefixed by a `$`, is a variable.  The variable means that anything can be given in place of it.  The value is stored in the name, `$a`.  Notice how `$a` is also referenced in the output.  This means that whatever value is stored in `$a` on the left, is used in place of `$a` on the right.

Considering this rule, the result of `(lit ((1 Int)))` is `1`.  This pattern has actually been encountered earlier.  The expression `1` returns `((1 Int))`.  This means that all integers that are given just return the literal and not the type.  However, considering the pattern, this is true *only* for integers.  Here is a list of values and their typed counterparts:

```
1 2 "3 4"

((1 Int) (2 Int) ("3 4" String))
```

Now, applying the rule to the typed list, here is the result:

```
1 
2 
lit ("3 4" String)
```

Because the pattern explicitly requires an `Int` as the type, the `String` remains as is.  What also remains is the `lit` symbol.  Since there was no match, the symbol is simply added to the list.  This is how types work in two-lang.  They are just associated in a list.  Take this pattern that when matched, adds two numbers:

```
(+ (($a Int) ($b Int))) = $a + $b
```

Now, the pattern, `+ 1 2` can be matched, and it produces `1 + 2`.  However, because the types need to match in the pattern, something like `+ "Hello, " "world"` does not work.

This is the complete syntax of two-lang.

# Concepts

In the following sections, various concepts will be explained that can be created in two-lang.

## Infix functions




