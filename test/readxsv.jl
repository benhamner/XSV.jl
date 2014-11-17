using Base.Test
using XSV

cases_path = splitdir(Base.source_path())[1]

@test readxsv("1,2,3\n4,5,6")[1][1]=="1"
@test readxsv("1,2,3\n4,5,6")[1][3]=="3"
@test readxsv("1,2,3\n4,5,6")[2][2]=="5"

@test readxsv("1;2;3\n4;5;6", delimiter=';')[1][3]=="3"
@test readxsv("1;2;3\n4;5;6", delimiter=';')[2][2]=="5"

@test readxsv("1;2;\"\"\"3\"\n4;5;6", delimiter=';')[1][3]=="\"3"
@test readxsv("1;2;\"\"\"3\"\n4;5;6", delimiter=';')[2][2]=="5"

@test readxsv("\"1\";2;\"3\"\n4;5;6",     delimiter=';')[1][3]=="3"
@test readxsv("1;2;3\n\"4\";\"5\";\"6\"", delimiter=';')[2][2]=="5"

@test readxsv("B1B;2;B3B\n4;5;6",   delimiter=';', quotechar='B')[1][3]=="3"
@test readxsv("1;2;3\nB4B;B5B;B6B", delimiter=';', quotechar='B')[2][2]=="5"

data = freadxsv(joinpath(cases_path, "cases/1.csv"))

@test data[2][2]=="dog"
@test data[3][2]=="cat"
@test data[3][3]=="11"
@test data[4][2]=="penguin"
@test data[4][3]=="12"
@test length(data)==4

