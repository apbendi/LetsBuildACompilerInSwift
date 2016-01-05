## Let's Build a Compiler (in Swift)

**WARNING: Work in progress!**

This repository is an attempt to work through [Let's Build a Compiler](http://www.compilers.iecc.com/crenshaw/), 
by Jack Crenshaw, in the Swift programing language.

If you're not familiar with that series, you should check it out; it is excellent.
Written in the late 80's, Crenshaw walks the reader through the implementation of a
recursive descent compiler. The approach is completely pragmatic, eschewing theory for
a learn-by-doing approach.

### Notes 

 * Crenshaw writes his compiler in Turbo Pascal 4 and the style of coding
  is very different from the way most software is developed today. It is a procedural approach,
  which was the norm at the time. This iteration is very much a *translation* of that code. I am **not**
  aiming to modernize the design, meaning you'll see global state and all kinds of fun mutations that
  might alarm an experienced Object Oriented or (God forbid!) Functional programmer in 2015.
  This is done intentionally, to make it easy to follow along with the examples provided.
 * Crenshaw's compiler emits assembly for a Motorola 68K processor running SK*DOS. My compiler emits...Swift.
 That's right, this is a compiler written in Swift that emits Swift. The output itself must be compiled, or
 (and this is rather convenient for development and debugging) copied into a playground. While I'm vaguely
 familiar with x86 assembly, the purpose of this excercise is to learn about how compilers work and to
 get better at Swift. As such, emitting Swift seems a reasonable approach. The Swift I'm producing largely 
 'emulates' the 68K. For example, I store values in Swift variables named `var d0` & `var d1` to mimic the 68K's
 d0 and d1 registers, where Crenshaw places values in his Assembly. Again, this is done intentionally to make
 working through his examples in parallel as painless as possible.

### Milestones

I'm actively working through the series part by part. As I complete sections, I'll link to milestone commits/branches 
in case you want to follow along.

 * A naive first pass at translating Crenshaw's "Cradle" can be found [Here](https://github.com/apbendi/LetsBuildACompilerInSwift/tree/Cradle). Note that as I worked through future examples
 issues with some parts of the Cradle did have to be addressed.
 * At the end of [Part 2](https://github.com/apbendi/LetsBuildACompilerInSwift/tree/Part2),
 we've created a parser that generates very inefficient Swift for evaluating
 single line mathematical expressions, so long as all numbers in the expression are single digits.
 * By the [middle of Part 3](https://github.com/apbendi/LetsBuildACompilerInSwift/tree/Part3),
 we've expanded on our parser from Part 2 to allow for the assignment and use of variables, and
 added rudimentary support for function calls, though without a way to define them.
 * In the [second half of Part 3](https://github.com/apbendi/LetsBuildACompilerInSwift/tree/part3-multi),
 Crenshaw detours to show us how to expand the parser handle multi-character
 variables and numbers, and to deal with whitespace graciously. This code itself, however, will be left behind in future
 sections.
 * [Part 4](https://github.com/apbendi/LetsBuildACompilerInSwift/tree/part4) is another detour,
 in which Crenshaw has us start with a fresh cradle and implement an *interpreter* rather than a compiler.
 This helps us understand the difference between the two.
 * In [Part 5](https://github.com/apbendi/LetsBuildACompilerInSwift/tree/part5)
 Crenshaw is laying the groundwork for control flow before we've implemented a boolean type. This is a
 chicken/egg situation. As such, the section feels a little weird because we can't generate any actual
 executable code, but must rely on placeholders for conditions and expressions.
 Additionally, my choice to emit Swift, rather than assembly, causes our implementation to
 depart a bit from Crenshaw. Assembly languages use branch statements that aren't easily "emulated" in Swift.
 If we were emitting C, we could have used `label` and `if(condition) goto label;` statements to mimic the assembly.
 This would have kept our implementation more parallel to the series. Swift doesn't have `label` or `goto`
 statements (not complaining!); instead we translate the grammar into equivalent Swift control constructs.
 This actually makes our implementation significantly simpler than Crenshaw's in certain places, as we avoid label counters and
 passing around label statements. There is still a lot to be learned by working through this section, even though it departs from
 the tutorial, but suffice it to say it would be a bit different if we were emitting C or Assembly.
 * By the [middle of Part 6](https://github.com/apbendi/LetsBuildACompilerInSwift/commit/1a72a3e47713d6eb74629ba39e87592e024b951b)
 we've built a parser that can handle Boolean expressions and incorporated our arithmetic expressions as well. Note that we again
 follow as closely to Crenshaw as possible while emitting Swift. This means that we're emitting `-1` for `true` and `0` as `false`
 the way he does in his 68K assembly.
 * At the [end of Part 6](https://github.com/apbendi/LetsBuildACompilerInSwift/tree/part6-2) we've built a pretty impressive
 parser. It can handle multi line programs, assignment statements, integer and boolean arithmetic, and control flow. You'll note
 that when integrating control flow with real boolean types, our previously discussed divergence from Crenshaw, due to the fact
 we're emitting Swift and not assembly, rears its head again. I was able to get most control statements working, but our 
 almost-but-not-really "emulation" of Crenshaw's assembly does cause some differences and issues. In particular, I don't have
 `while` (or `repeat`-`until`) working properly. Still, our little 'language' is pretty functional and we're mapping close to the
 series.

### Future

In the short term, I plan to work through the full series.
In the medium term, I hope to better organize the repo to include clean, completed code for each section on the master branch, 
so this can be a useful reference for future learners who also want to work through this series in Swift. In the longer term, I'd
like to refactor the final product into a more modern design and possibly even update the tutorial itself
to essentially build an updated version of Crenshaw's series. We'll see how far I'm able to get.
