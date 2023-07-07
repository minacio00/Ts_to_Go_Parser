%{
  #include <stdio.h>
  #include <string.h>
  #include "testParser.tab.h"  // Include the generated parser header file
  char *stringpoool(char *);
%}
%option yylineno
identifier       [a-zA-Z_][a-zA-Z0-9_]*
        
%%

"import"        { return IMPORT; }
"export"        { return EXPORT; }
"let"           { return LET; }
"const"         { return CONST; }
"var"           { return VARTK; }
"function"      { return FUNCTION; }
"class"         { return CLASS; }
"interface"     { return INTERFACE; }
"number"        { yylval.string = strdup("int"); return TYPE;}
"string"        { yylval.string = strdup("string"); return TYPE;}
"boolean"       { yylval.string = strdup("bool"); return TYPE;}
"true"          { yylval.string = strdup("true"); return BOOL;}
"false"         { yylval.string = strdup("false"); return BOOL;}
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"constructor"   { return CONSTRUCTOR; }
"static"        { return STATIC; }
"public"        { return PUBLIC; }
"void"          { return VOID; }
"any"           { return ANY; }
"<="            {  return(COMPARISSON); yylval.string = strdup("<=");  }
">="            {  return(COMPARISSON); yylval.string = strdup(">=");  }
"!="            {  return(COMPARISSON); yylval.string = strdup("!=");  }
"=="             {  return(COMPARISSON); yylval.string = strdup("==");  }
">"             {  return(COMPARISSON); yylval.string = strdup(">");  }
"<"             {  return(COMPARISSON); yylval.string = strdup("<");  }

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
