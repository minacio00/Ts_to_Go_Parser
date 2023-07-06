translate:lexer.l testParser.y
	bison --debug -d testParser.y
	flex lexer.l
	cc -g -o translate testParser.tab.c sym.c lex.yy.c -lfl
