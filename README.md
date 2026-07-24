# ipscanner
ipscanner in flex

### files
- <a href="https://github.com/heinrichelsigan/ipscanner/blob/main/Makefile">Makefile</a>
- <a href="https://github.com/heinrichelsigan/ipscanner/blob/main/ipscanner.yy">ipscanner.yy</a>
- <a href="https://github.com/heinrichelsigan/ipscanner/blob/main/.gitignore">.gitignore</a>
- <a href="https://github.com/heinrichelsigan/ipscanner/blob/main/LICENSE">LICENSE</a>
- <a href="https://github.com/heinrichelsigan/ipscanner/blob/main/README.md">README.md</a>


### build ipscanner
`make clean; make all`

### example of ipscanner
`cat /var/log/kern.log | ./ipscanner --nomatch "224." |less`

### usage of ipscanner

`./ipscanner --help`







