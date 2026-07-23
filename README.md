# ipscanner
ipscanner in flex

# Usage of ipscanner
`
cat /var/log/kern.log | ./ipscanner --nomatch "224." |less
`


## Makefile for ipscanner
`
ipscanner:
        flex -v --full -o ipscanner.c ipscanner.yy
        gcc -Wimplicit-function-declaration -o ipscanner ipscanner.c

all: ipscanner

clean:
        rm -f ipscanner.c ipscanner
`

