XSV.jl
======

[![Build Status](https://travis-ci.org/benhamner/XSV.jl.svg?branch=master)](https://travis-ci.org/benhamner/XSV.jl)
[![Coverage Status](https://coveralls.io/repos/benhamner/XSV.jl/badge.png?branch=master)](https://coveralls.io/r/benhamner/XSV.jl?branch=master)
[![Package Evaluator](http://iainnz.github.io/packages.julialang.org/badges/XSV_release.svg)](http://iainnz.github.io/packages.julialang.org/?pkg=XSV&ver=release)

Simple tool for reading syntactically correct (RFC 4180) CSV files in a streaming manner. Works with different delimiters, quote characters, and unicode.

Working in a streaming manner:

    > using XSV
    > for row=iterxsv("cat,1\ndog,2")
    >     println(row)
    > end
    ASCIIString["cat","1"]
    ASCIIString["dog","2"]

`fiterxsv` takes in a filepath:

    > io = open("a.tsv", "w")
    > write(io, "animal\ttype\n😸\t*mammal*\n*penguin*\t*bird*")
    > close(io)
    > 
    > for row=fiterxsv("a.tsv", delimiter='\t', quotechar='*', strtype="utf8")
    >     println(row)
    > end
    UTF8String["animal","type"]
    UTF8String["😸","mammal"]
    UTF8String["penguin","bird"]

Reading everything in at once:

     > readxsv("cat,1\ndog,2")
     2-element Array{Array{ASCIIString,1},1}:
      ASCIIString["cat","1"]
      ASCIIString["dog","2"]

TODO
====

 - Header support
 - Speed benchmarks
 - Documentation
 - More extensive unit tests
