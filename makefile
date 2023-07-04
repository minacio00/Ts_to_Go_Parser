translate:	lexer.l testParser.y
		bison -d testParser.y
		flex lexer.l
		cc -o $@ testParser.tab.c lex.yy.c -lfl