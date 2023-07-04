%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  FILE * output;
%}

%code requires {
    struct VariableDeclarator {
        char identifier[1000];
        char* initializer;
    } *variableDeclarator;
}
%union {
        int number;
        char *string;
        struct VariableDeclarator args;
}


%token <string> IDENTIFIER
%token <string> STRING_LITERAL
%token <string> INTEGER_LITERAL
%token <string> FLOAT_LITERAL
%token <string> IMPORT EXPORT LET CONST VAR
%token <string> ASSGNOP
%token <string> FUNCTION CLASS INTERFACE TYPE
%token <string> IF ELSE WHILE CONSTRUCTOR STATIC PUBLIC COMMA EQUAL
%token NUMBER STRING  BOOL

%type<string> variable_declarators initializer variable_declarator id_seq

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
                     |id_seq IDENTIFIER ':' NUMBER {
                      printf("cheguei no declarators\n");
                      // printf("%s id do vd\n", $2);

                      if($<args.identifier>1[0] == '\0'){
                       fprintf(output, "var %s int;\n", $2);
                       printf("%s = &1\n", $<args.identifier>1);
                      } else {
                        fprintf(output, "var %s%s int;\n",$<args.identifier>1, $2);
                      }
                      // free($1); // Free the memory allocated for id_seq
                      //  fprintf(output, "var %s %s int;\n", $<args.identifier>1, $2);
                     } //todo: deve ter tipo por exemplo: int, float
                     |id_seq IDENTIFIER ':' STRING
                     |id_seq IDENTIFIER ':' BOOL
;
id_seq : /* empty */
        |id_seq IDENTIFIER COMMA {
            // Generate output 
            strcat($<args.identifier>$, $2);
            strcat($<args.identifier>$, ",");
            printf("%s,", $2);
            printf("cheguei no id_seq %s \n", $2);
            // fprintf(output, "%s,", $2);
           
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
  output= fopen("output.c", "w"); //todo: .go e declaraçãode main no go
  yyparse();

  fclose(output);  // Close output file

  return 0;
}

void yyerror(const char *s) {
  fprintf(stderr, "Parsing error: %s\n", s);
  exit(1);
}