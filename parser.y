%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char*);
#define YYSTYPE char *
%}

%token T_String T_Number T_Identifier T_Int T_Print
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

%left '+' '-'
%left '*' '/'
%right U_neg

%%

S:
    Stmt                        { /* empty */ }
|   S Stmt                      { /* empty */ }
;

Stmt:
    SyntaxVersion               { /* empty */ }
|   T_AdapterBrd T_Identifier   '{' '}' { printf("%s", $1); }
|   T_AdapterBrd T_Identifier '{' Pins MaxSite '}'
;

Pins:
    /* empty */
|   Pins T_Pin '{' Pin_subs '}'
;

Pin_subs: /* U1709 */
    /* empty */
|   Pin_subs T_Name '=' T_Identifier ';'
|   Pin_subs T_Ppid '=' T_String ';'
|   Pin_subs T_XCoord '=' '(' T_Number ',' T_Number ')' ';'
|   Pin_subs T_Shape '=' T_Number ';'
|   Pin_subs T_PinType '=' T_Identifier ';'
|   Pin_subs Pin_Connection
;

Pin_Connection:
    /* empty */
|   T_Connection '[' T_Number ']' '{' Pin_Connection_items '}'
;

Pin_Connection_items:
    /* empty */
|   Pin_Connection_items T_Instrument '{' T_String '}' ';'
        { printf("instrument: %s", $4); }
|   Pin_Connection_items T_Resource '=' T_Identifier ';'
|   Pin_Connection_items Channel_def 
        { printf(", %s\n", $2); }
;

Channel_def:
    /* empty */
|   T_SlotChannel '[' T_Number ']' '=' T_Identifier '.' T_Identifier ';' {
        int sz = snprintf(NULL, 0, "%s%s%s", $6, ".", $8);
        char buf[sz+1];
        snprintf(buf, sizeof buf, "%s%s%s", $6, ".", $8);
        $$ = malloc(sz + 1);
        snprintf($$, sizeof buf, "%s%s%s", $6, ".", $8);
    }
|   Channel_def T_SlotChannel '[' T_Number ']' '=' T_Identifier '.' T_Identifier ';' {
        char * tmp = $$;
        int sz = snprintf(NULL, 0, "%s, %s%s%s", tmp, $7, ".", $9);
        char buf[sz+1];
        $$ = malloc(sz + 1);
        snprintf($$, sizeof buf, "%s, %s%s%s", tmp, $7, ".", $9);
        free(tmp);
    }
;

MaxSite:
    T_MaxSite '=' T_Number ';'
;

SyntaxVersion:
    T_Head ':' T_Version ';' { printf("version: %s\n", $3); }
;



%%

int main() {
    return yyparse();
}
