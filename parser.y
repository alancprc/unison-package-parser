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
UN_MaxSite
UN_PinGroup
UN_Expression
UN_Group
UN_Type
UN_String

%right '='
%right UN_PinType UN_Name UN_Resource UN_Ppid UN_XCoord UN_Shape UN_Connection UN_Instrument
UN_SlotChannel
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
    UN_PinType T_Identifier '{' UN_Type '=' T_Identifier ';' '}'
|   UN_PinGroup T_Identifier '{' UN_Group '=' Expression '}'
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
;

Connection_item:
    Connection_item Connection_item %prec '='
|   UN_Instrument '{' T_String '}' ';'   { printf(",\t%s", $3); }
|   UN_Resource '=' T_Identifier ';'
|   Channel                             { printf(", %s", $1); }
;

Channel:
    UN_SlotChannel '[' T_Number ']' '=' T_Identifier '.' T_Identifier ';'    {
        int sz = snprintf(NULL, 0, "%s%s%s", $6, ".", $8);
        $$ = malloc(sz + 1);
        snprintf($$, sz + 1, "%s%s%s", $6, ".", $8);
    }
;

__MaxSite:
    UN_MaxSite '=' T_Number ';'  { printf("\n"); }
;

SyntaxVersion:
    UN_Head ':' UN_Version ';' { printf("%s\n", $3); }
;

%%

int main() {
    return yyparse();
}
