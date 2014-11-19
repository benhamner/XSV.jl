module XSV
#    using
#        DataFrames,

    export
        # types

        # methods
        iterxsv,
        iterxsvh,
        fiterxsv,
        fiterxsvh,
        freadxsv,
        readxsv

    include("readxsv.jl")
end