OUT      = tcc
TESTFILE = test.c
SCANNER  = scanner.l
PARSER   = parser.y

CC       = gcc
OBJ      = lex.yy.o y.tab.o
TESTOUT  = $(basename $(TESTFILE)).asm
OUTFILES = lex.yy.c y.tab.c y.tab.h y.output $(OUT)

.PHONY: build test simulate clean run

all: build run

build: $(OUT)

test: $(TESTOUT)

simulate: $(TESTOUT)
	python pysim.py $< 

clean:
	rm -f *.o $(OUTFILES)

$(TESTOUT): $(TESTFILE) $(OUT)
	./$(OUT) < $< > $@

$(OUT): $(OBJ)
	$(CC) -o $(OUT) $(OBJ)

lex.yy.c: $(SCANNER) y.tab.c
	flex $<

y.tab.c: $(PARSER)
	bison -vdty $<

run:
	./$(OUT) < $(TESTFILE)
