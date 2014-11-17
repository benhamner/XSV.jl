using Base.Test
using XSV

@test readxsv("1,2,3\n4,5,6")[1][1]=="1"
@test readxsv("1,2,3\n4,5,6")[1][3]=="3"
@test readxsv("1,2,3\n4,5,6")[2][2]=="5"

@test readxsv("1;2;3\n4;5;6", delimiter=';')[1][3]=="3"
@test readxsv("1;2;3\n4;5;6", delimiter=';')[2][2]=="5"

@test readxsvs("1,2,3\n4,5,6")[1][1]=="1"
@test readxsvs("1,2,3\n4,5,6")[1][3]=="3"
@test readxsvs("1,2,3\n4,5,6")[2][2]=="5"

@test readxsvs("1;2;3\n4;5;6", delimiter=';')[1][3]=="3"
@test readxsvs("1;2;3\n4;5;6", delimiter=';')[2][2]=="5"
