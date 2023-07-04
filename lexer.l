%{
  #include <stdio.h>
  #include <string.h>
  #include "testParser.tab.h"  // Include the generated parser header file
%}

identifier       [a-zA-Z_][a-zA-Z0-9_]*

%%

"import"        { return IMPORT; }
"export"        { return EXPORT; }
"let"           { return LET; }
"const"         { return CONST; }
"var"           { return VAR; }
"function"      { return FUNCTION; }
"class"         { return CLASS; }
"interface"     { return INTERFACE; }
"number"        { return NUMBER;}
"string"        { return STRING;}
"boolean"       { return BOOL;}
"type"          { return TYPE; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"constructor"   { return CONSTRUCTOR; }
"static"        { return STATIC; }
"public"        { return PUBLIC; }
":="            { return ASSGNOP; }
","             { return COMMA; }
"="             { return EQUAL; }

{identifier}    { yylval.string = strdup(yytext); return IDENTIFIER; }

\"([^\\\n]|(\\.))*?\"   { yylval.string = strdup(yytext); return STRING_LITERAL; }
[0-9]+                  { yylval.string = strdup(yytext); return INTEGER_LITERAL; }
[0-9]+"."[0-9]*         { yylval.string = strdup(yytext); return FLOAT_LITERAL; }

[ \t\r\n;]+    // Ignore whitespace

.             { return yytext[0]; }  // Return individual characters as tokens

%%

int yywrap() {
  return 1;
}
