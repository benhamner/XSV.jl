module XSV
#    using
#        DataFrames,

    export
        # types

        # methods
        iterxsv,
        iterxsvh,
        iterxsvht,
        fiterxsv,
        fiterxsvh,
        fiterxsvht,
        freadxsv,
        genxsv,
        readxsv

    include("genxsv.jl")
    include("readxsv.jl")
end