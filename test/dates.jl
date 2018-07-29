using Dates

@testset "Date.TimeTypes" begin

r = Parsers.parse(Parsers.defaultparser, IOBuffer(""), Date)
@test r.result === missing
@test r.code == Parsers.INVALID
@test r.b === 0x00
r = Parsers.parse(Parsers.defaultparser, IOBuffer("2018-01-01"), Date)
@test r.result === Date(2018, 1, 01)
@test r.code == Parsers.OK
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.defaultparser, IOBuffer("2018-01-01"), DateTime)
@test r.result === DateTime(2018, 1, 01)
@test r.code == Parsers.OK
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.defaultparser, IOBuffer("01:02:03"), Time)
@test r.result === Time(1, 2, 3)
@test r.code == Parsers.OK
@test r.b === UInt8('3')

r = Parsers.parse(Parsers.Quoted(), IOBuffer(""), Date)
@test r.result === missing
@test r.code == Parsers.INVALID
@test r.b === 0x00
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"\""), Date)
@test r.result === missing
@test r.code == Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("2018-01-01"), Date)
@test r.result === Date(2018, 1, 01)
@test r.code == Parsers.OK
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"2018-01-01\""), Date)
@test r.result === Date(2018, 1, 01)
@test r.code == Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"2018-01-01"), DateTime)
@test r.result === missing
@test r.code == Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Quoted('"', '"'), IOBuffer("\"01\"\"02\"\"03\""), Time; dateformat=dateformat"HH\"\"MM\"\"SS")
@test r.result === Time(1, 2, 3)
@test r.code == Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"abcd\""), Date)
@test r.result === missing
@test r.code == Parsers.INVALID
@test r.b === UInt8('"')

r = Parsers.parse(Parsers.Sentinel(["NA"]), IOBuffer("NA"), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Sentinel(["\\N"]), IOBuffer("\\N"), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('N')
r = Parsers.parse(Parsers.Sentinel(["NA"]), IOBuffer("NA2"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('2')
r = Parsers.parse(Parsers.Sentinel(["-", "NA", "\\N"]), IOBuffer("-"), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('-')
r = Parsers.parse(Parsers.Sentinel(["£"]), IOBuffer("£"), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === 0xa3
r = Parsers.parse(Parsers.Sentinel(["NA"]), IOBuffer("null"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('l')
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer("null"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('l')
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer(""), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Sentinel(String["NA"]), IOBuffer(""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === 0x00
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer(","), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8(',')
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer("1,"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8(',')

r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer(""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === 0x00
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]))), IOBuffer("\"\""), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("NA"), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA\""), Date)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA2"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('2')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA2\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"+1\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"+1"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NAabc\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA\\\"abc\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"')), IOBuffer("\"1ab\"\"c\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"')), IOBuffer("\"1ab\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"')), IOBuffer("\"1ab\"\""), Date)
@test r.result === missing
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"2018-01-01\""), Date)
@test r.result === Date(2018,1,1)
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"2018-01-01"), Date)
@test r.result === missing
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('1')

end
