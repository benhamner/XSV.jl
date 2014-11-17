module XSV
#    using
#        DataFrames,

    export
        # types

        # methods
        freadxsv,
        readxsv

    include("readxsv.jl")
end