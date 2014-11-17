XSV.jl
======

[![Build Status](https://travis-ci.org/benhamner/XSV.jl.svg?branch=master)](https://travis-ci.org/benhamner/XSV.jl)
[![Coverage Status](https://coveralls.io/repos/benhamner/XSV.jl/badge.png?branch=master)](https://coveralls.io/r/benhamner/XSV.jl?branch=master)

Simple tool for reading syntactically correct (RFC 4180) CSV files in a streaming manner. Works with different delimiters, quote characters, and unicode.

Working in a streaming manner (string as a d):

     > using XSV
     > for row=iterxsv("cat,1\ndog,2")
     >    println(row)
     > end
     ASCIIString["cat","1"]
     ASCIIString["dog","2"]

Reading everything in at once:

     > readxsv("cat,1\ndog,2")
     2-element Array{Array{ASCIIString,1},1}:
      ASCIIString["cat","1"]
      ASCIIString["dog","2"]

TODO
====

 - Additional file helpers
 - Header support
 - Speed benchmarks
 - Documentation
 - More extensive unit tests
