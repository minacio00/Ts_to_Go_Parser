%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sym.h"

extern int yylineno;
extern VAR *SymTab;

int semerro=0;
#define _UNDECL  0
#define _NUMBER  1
#define _BOOL    2
#define _STRING  3
#define _ANY     4
int multipleVarsType= 0; // I made this to keep track of the type when parsing multiple vars in the same line;

#define AddVAR(n,t) SymTab=MakeVAR(n,t,SymTab)
#define ASSERT(x,y) if(!(x)) { printf("%s na  linha %d\n",(y),yylineno); semerro=1; }
FILE * output;
char* identifierList = NULL;
char* exp_string = NULL;

int getType(char* type){
  if (strcmp(type, "number") == 0) {
        return 1;
    } else if (strcmp(type, "string") == 0) {
        return 3;
    } else if (strcmp(type, "boolean") == 0) {
        return 2;
    } else {
        return 4; // return any
    }
}
void appendParamsIdentifier (char** list, char* identifier, char* type){
  //buffer para parametros de funcao
  if (*list == NULL) {
        char* comma = ",";
        *list = strdup(identifier);
        printf("id: %s\n", identifier);
        printf("lista antes: %s\n", *list);
        size_t len = strlen(*list);
        size_t idLen = strlen(identifier);
        size_t typeLen = strlen(type);
        *list = realloc(*list, len + idLen + typeLen + 6);
        // strcat(*list, identifier);
        strcat(*list, type);
        strcat(*list, comma);
        printf("lista atual: %s\n", *list);
        
    } else {
        char* comma = ",";
        size_t len = strlen(*list);
        printf("lista antes: %s\n", *list);
        size_t idLen = strlen(identifier);
        size_t typeLen = strlen(type);
        *list = realloc(*list, len + idLen + typeLen + 6);
        strcat(*list, identifier);
        strcat(*list, type);
        strcat(*list, comma);
        printf("lista atual: %s\n", *list);
        // identifierList = *list;
    }
}
void appendIdentifier(char** list, char* identifier) {
  //buffer para declaracao de multiplas variáveis
    if (*list == NULL) {
        char* comma = ",";
        *list = strdup(identifier);
        size_t len = strlen(*list);
        size_t idLen = strlen(identifier);
        *list = realloc(*list, len + idLen + 2);
        strcat(*list, comma);
        
    } else {
        char* comma = ",";
        size_t len = strlen(*list);
        size_t idLen = strlen(identifier);
        *list = realloc(*list, len + idLen + 2);
        strcat(*list, identifier);
        strcat(*list, comma);
        printf("lista atual: %s\n", *list);
        // identifierList = *list;
    }
}

void printIdentifierList(char* list) {
    printf("%s\n", list);
    fprintf(output, "%s\n", list);
    free(list);
}
%}

%union {
    int number;
    char* string;
}

%token <string> IDENTIFIER
%token <string> STRING_LITERAL
%token <string> INTEGER_LITERAL
%token <string> FLOAT_LITERAL
%token <string> IMPORT EXPORT LET CONST VARTK CONSOLE
%token <string> COMPARISSON
%token <string> FUNCTION CLASS INTERFACE 
%token <string> TYPE VOID ANY LOG
%token <string> IF ELSE WHILE CONSTRUCTOR STATIC PUBLIC COMMA
%token <string> BOOL
%token NUMBER STRING 
%token fn_body
%type <string> variable_declarators initializer
%type <string> id_seq parameter_list fn_types exp command commands

%left COMPARISSON
%left '-' '+'
%left '*' '/'
%right '^'

%%
program: statement_list
    | /* empty */
    ;
statement_list: statement
    | statement_list statement
    ;
statement: import_statement
    | export_statement
    | variable_declaration
    | commands
    ;
import_statement: IMPORT STRING_LITERAL
    ;
export_statement: EXPORT /* more export types */
    ;
variable_declaration: LET variable_declarators {
        printf("cheguei no let \n");
    }
    | VARTK variable_declarators
    | CONST IDENTIFIER '=' initializer { fprintf(output, "const %s = %s\n",$2, $4);}
    | FUNCTION IDENTIFIER '(' parameter_list ')' fn_types '{' commands '}' {
     
      if (identifierList == NULL) {
        printf("lista nula");
        fprintf(output, "func %s (%s)%s {\n \n}\n",$2, identifierList, $6);
      }
      else {
        printf("lista\n");
        // fprintf(output, "func %s (%s)%s {\n \n}\n",$2, $4, $6);
        fprintf(output, "func %s (%s)%s {\n \n}\n",$2, identifierList, $6);
        free(identifierList);
        identifierList = NULL;
      }
    }
    ;
    fn_types:{$$ = " interface{}";}
    | ':'TYPE {$$ = $2;}
    | ':'VOID {$$ = " ";}
    | ':'ANY {$$ = "interface{}";}
    ;
    parameter_list: IDENTIFIER fn_types {
                              printf("cheguei na id types\n");
                              appendParamsIdentifier(&identifierList, $1, $2);
                              $$ = identifierList; 
    }
    |parameter_list ',' IDENTIFIER {appendParamsIdentifier(&identifierList, $3, " interface{}"); $$ = identifierList;}
    |parameter_list ',' IDENTIFIER ':' fn_types {appendParamsIdentifier(&identifierList, $3, $5); $$ = identifierList;}
    ;
    commands: command
    |commands command { fprintf (output,";\n"); }
    ;
    command: IF '(' exp ')' '{' commands '}' {printf("if"); fprintf(output, "if %s {\n%s}", exp_string, $6); }
    | CONSOLE'.'LOG'('STRING_LITERAL')' {
                                    char buffer[50];
                                    sprintf(buffer,"\tfmt.println(%s)\n",$5);
                                    $$ = buffer;
                                    }
    ;
variable_declarators: /* empty */
                    | id_seq IDENTIFIER ':' TYPE {
                        if (identifierList == NULL) {
                          printf("cheguei no declarators: %s %s\n", $2, $4);
                          fprintf(output, "var %s %s\n",$2, $4);
                          AddVAR($2,getType($4));
                          multipleVarsType = getType($4);
                          VAR *ptr=FindVAR($2);
                          char str[50];
                          sprintf(str, "\n%s already exists", $2);
                          if (ptr != NULL) {
                            printf("%s", str);
                          }
                          
                          ListVars();
                          //todo: check for already declared vars
                        }
                        else {
                          fprintf(output, "var %s%s %s\n", identifierList, $2, $4);
                          AddVAR($2,getType($4));
                          multipleVarsType = getType($4);
                          // printIdentifierList(identifierList);
                          free(identifierList);
                          char str[50];
                          VAR *ptr=FindVAR($2);
                          sprintf(str, "\n%s already exists", $2);
                          if (ptr != NULL) {
                            printf("%s", str);
                          }
                          ListVars();
                          identifierList = NULL;
                        }
                    }
                    ;
id_seq: /**/
      | id_seq IDENTIFIER ',' {
        // strcat(identifierList, ",");
        appendIdentifier(&identifierList, $2);
        char str[50];
        VAR *ptr=FindVAR($2);
        sprintf(str, "\n%s already exists", $2);
        if (ptr != NULL) {
          printf("%s", str);
        }
        AddVAR($2,multipleVarsType);
      }
      ;

initializer:    STRING_LITERAL {$$ = $1;}
                |   INTEGER_LITERAL {$$ = $1;}
                |   FLOAT_LITERAL {$$ = $1;}
                |   BOOL {$$ = $1;}
;
exp: INTEGER_LITERAL {
        size_t token_length = strlen($1);
        size_t exp_string_size = strlen(&exp_string);
        exp_string = realloc(exp_string, exp_string_size + token_length + 1);
        strcat(exp_string, $1);
        // exp_string_size += token_length;
    }
    | FLOAT_LITERAL {
        size_t token_length = strlen($1);
        size_t exp_string_size = strlen(exp_string);
        exp_string = realloc(exp_string, exp_string_size + token_length + 1);
        strcat(exp_string, $1);
    }
    | IDENTIFIER {
        size_t token_length = strlen($1);
        size_t exp_string_size = strlen(exp_string);
        exp_string = realloc(exp_string, exp_string_size + token_length + 1);
        strcat(exp_string, $1);
    }
    | exp '+' exp {
        exp_string = strcat(exp_string, " + ");
    }
    | exp '-' exp {
        exp_string = strcat(exp_string, " - ");
    }
    | exp '*' exp {
        exp_string = strcat(exp_string, " * ");
    }
    | exp '/' exp {
        exp_string = strcat(exp_string, " / ");
    }
    | '(' {
        exp_string = strcat(exp_string, "(");
    }
    | ')' {
        exp_string = strcat(exp_string, ")");
    }
    ;
%%

int main() {
  // #ifdef YYDEBUG
  // yydebug = 1;
  // #endif
  output= fopen("output.go", "w");
  fprintf(output, "package main\n\n");
  init_stringpool(2000);
  yyparse();

  fclose(output);  // Close output file

  return 0;
}

void yyerror(const char *s) {
  fprintf(stderr, "Parsing error: %s\n", s);
  exit(1);
}