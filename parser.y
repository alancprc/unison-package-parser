%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char*);
#define YYSTYPE char *
%}

%token T_String T_Number T_Identifier T_Int
UN_Head
UN_Version
UN_AdapterBrd
UN_Pin
UN_PinType
UN_Name
UN_Resource
UN_Ppid
UN_XCoord
UN_Shape
UN_Connection
UN_Instrument
UN_SlotChannel
UN_TesterChannel
UN_MaxSite
UN_PinGroup
UN_Expression
UN_Group
UN_Type
UN_Comment
UN_Pin_Direction
UN_String

%right '='
%right UN_PinType UN_Name UN_Resource UN_Ppid UN_XCoord UN_Shape UN_Connection UN_Instrument
UN_SlotChannel
UN_TesterChannel
UN_Comment
UN_Pin_Direction
%left '+' '-'
%left '*' '/'
%right U_neg
%right '{'
%left  '}'
%left ';'

%%

S:
    Stmt                        { /* empty */ }
|   S Stmt                      { /* empty */ }
|   error                       { yyerrok;    }
;

Stmt:
    SyntaxVersion               { /* empty */ }
|   UN_AdapterBrd T_Identifier '{' __Pin __MaxSite '}'
|   IGNORE
;

IGNORE:
    UN_Comment '=' T_String ';'
|   UN_PinGroup T_Identifier '{' UN_Group '=' Expression '}'
|   PinType
;

Expression:
    UN_Expression '{' UN_String '=' T_String ';' '}'
;


__Pin:
    /* empty */
|   __Pin UN_Pin '{' Pin_item '}'
;

/* U1709 */
Pin_item:
    Pin_item Pin_item %prec ';'
|   UN_Name '=' T_Identifier ';'
|   UN_Ppid '=' T_String ';'
|   UN_XCoord '=' '(' T_Number ',' T_Number ')' ';'
|   UN_Shape '=' T_Number ';'
|   UN_PinType '=' T_Identifier ';'  { printf("\n%s", $3); }
|   UN_Connection '[' T_Number ']' '{' Connection_item '}'
|   IGNORE
;

Connection_item:
    Connection_item Connection_item %prec '='
|   UN_Instrument '{' T_String '}' ';'   { printf(",\t%s", $3); }
|   UN_Resource '=' T_Identifier ';'
|   Channel                             { printf(", %s", $1); }
|   Channel_U4                          { printf(", %s", $1); }
|   /* empty */
;

Channel:
    UN_SlotChannel '[' T_Number ']' '=' T_Identifier '.' T_Identifier ';'    {
        int sz = snprintf(NULL, 0, "%s%s%s", $6, ".", $8);
        $$ = malloc(sz + 1);
        snprintf($$, sz + 1, "%s%s%s", $6, ".", $8);
    }
;

Channel_U4:
    UN_TesterChannel '[' T_Number ']' '=' Channel_NO_U4 ';'    {
        if (atoi($3) == 1) {
          int sz = snprintf(NULL, 0, "\t\"\", %s", $6);
          $$ = malloc(sz + 1);
          snprintf($$, sz + 1, "\t\"\", %s", $6);
        } else {
          int sz = snprintf(NULL, 0, "%s", $6);
          $$ = malloc(sz + 1);
          snprintf($$, sz + 1, "%s", $6);
        }
    }
;

Channel_NO_U4:
    T_Number | T_Identifier;

__MaxSite:
    UN_MaxSite '=' T_Number ';'  { printf("\n"); }
|   /* empty when single site*/
;

PinType:
    UN_PinType T_Identifier '{' PinType_item '}' ;
    

PinType_item:
    PinType_item PinType_item
|   UN_Comment '=' T_String ';'
|   UN_Type '=' T_Identifier ';'
|   UN_Pin_Direction '=' T_Identifier ';'
;

SyntaxVersion:
    UN_Head ':' UN_Version ';' { printf("SyntaxVersion,%s\n", $3+14); }
;

%%

int main() {
    return yyparse();
}
