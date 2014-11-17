module XSV
#    using
#        DataFrames,

    export
        # types

        # methods
        iterxsv,
        fiterxsv,
        freadxsv,
        readxsv

    include("readxsv.jl")
end