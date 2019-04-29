%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char*);
#define YYSTYPE char *
%}

%token T_String T_Number T_Identifier T_Int
T_Head
T_Version
T_AdapterBrd
T_Pin
T_PinType
T_Name
T_Resource
T_Ppid
T_XCoord
T_Shape
T_Connection
T_Instrument
T_SlotChannel
T_MaxSite

%right '='
%right T_PinType T_Name T_Resource T_Ppid T_XCoord T_Shape T_Connection T_Instrument
T_SlotChannel
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
;

Stmt:
    SyntaxVersion               { /* empty */ }
|   T_AdapterBrd T_Identifier '{' __Pin __MaxSite '}'
;

__Pin:
    /* empty */
|   __Pin T_Pin '{' Pin_item '}'
;

/* U1709 */
Pin_item:
    Pin_item Pin_item %prec ';'
|   T_Name '=' T_Identifier ';'
|   T_Ppid '=' T_String ';'
|   T_XCoord '=' '(' T_Number ',' T_Number ')' ';'
|   T_Shape '=' T_Number ';'
|   T_PinType '=' T_Identifier ';'  { printf("\n%s", $3); }
|   T_Connection '[' T_Number ']' '{' Connection_item '}'
;

Connection_item:
    Connection_item Connection_item %prec '='
|   T_Instrument '{' T_String '}' ';'   { printf(",\t%s", $3); }
|   T_Resource '=' T_Identifier ';'
|   Channel                             { printf(", %s", $1); }
;

Channel:
    T_SlotChannel '[' T_Number ']' '=' T_Identifier '.' T_Identifier ';'    {
        int sz = snprintf(NULL, 0, "%s%s%s", $6, ".", $8);
        $$ = malloc(sz + 1);
        snprintf($$, sz + 1, "%s%s%s", $6, ".", $8);
    }
;

__MaxSite:
    T_MaxSite '=' T_Number ';'  { printf("\n"); }
;

SyntaxVersion:
    T_Head ':' T_Version ';' { printf("%s\n", $3); }
;

%%

int main() {
    return yyparse();
}
