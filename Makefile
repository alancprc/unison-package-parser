OUT      = adapter_parser
TESTFILE = test_adapter.uno
SCANNER  = scanner.l
PARSER   = parser.y

CC       = gcc
OBJ      = lex.yy.o y.tab.o
OUTFILES = lex.yy.c y.tab.c y.tab.h y.output $(OUT)

.PHONY: build clean run

all: build run

build: $(OUT)

clean:
	rm -f *.o $(OUTFILES)

$(OUT): $(OBJ)
	$(CC) -o $(OUT) $(OBJ)

lex.yy.c: $(SCANNER) y.tab.c
	flex $<

y.tab.c: $(PARSER)
	bison -vdty $<

run:
	./$(OUT) < $(TESTFILE)
