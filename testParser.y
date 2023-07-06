%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
FILE * output;
char* identifierList = NULL;

void appendIdentifier(char** list, char* identifier) {
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
%token <string> IMPORT EXPORT LET CONST VAR
%token <string> ASSGNOP
%token <string> FUNCTION CLASS INTERFACE TYPE
%token <string> IF ELSE WHILE CONSTRUCTOR STATIC PUBLIC COMMA EQUAL
%token NUMBER STRING BOOL

%type <string> variable_declarators initializer variable_declarator
%type <string> id_seq

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
    | /* more statement types */
    ;
import_statement: IMPORT STRING_LITERAL
    ;
export_statement: EXPORT /* more export types */
    ;
variable_declaration: LET variable_declarators {
        printf("cheguei no let \n");
    }
    | CONST variable_declarators
    | VAR variable_declarators
    ;
variable_declarators: /* empty */
    | id_seq IDENTIFIER ':' NUMBER {
        if (identifierList == NULL) {
          printf("cheguei no declarators: %s int\n", $2);
          fprintf(output, "var %s int\n",$2);
        }
        else {
          fprintf(output, "var %s%s int\n", identifierList, $2);
          // printIdentifierList(identifierList);
          free(identifierList);
          identifierList = NULL;
        }
    }
    | id_seq IDENTIFIER ':' STRING
    | id_seq IDENTIFIER ':' BOOL
    ;
id_seq: {$$ = NULL;}
      | id_seq IDENTIFIER COMMA {
        // strcat(identifierList, ",");
        appendIdentifier(&identifierList, $2);
        printf("cheguei no id_seq %s\n", $2);
    }
    ;
variable_declarator: IDENTIFIER  // adicionar variavel a tabela sem inicializar
                    | IDENTIFIER EQUAL initializer {
                        $<args.identifier>$ = $1;
                       $<args.initializer>$= $3;}
;
initializer:    STRING_LITERAL
                |   INTEGER_LITERAL
                |   FLOAT_LITERAL
;

%%

int main() {
  output= fopen("output.go", "w"); //todo: .go e declaraçãode main no go
  fprintf(output, "package main\n");
  yyparse();

  fclose(output);  // Close output file

  return 0;
}

void yyerror(const char *s) {
  fprintf(stderr, "Parsing error: %s\n", s);
  exit(1);
}