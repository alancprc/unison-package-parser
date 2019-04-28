%{
#include <stdio.h>
#include <stdlib.h>
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
|   T_AdapterBrd T_Identifier '{' Pin_def MaxSite_def '}'
;

Pin_def:
    /* empty */
|   T_Pin '{' Pin_property '}' Pin_def
;

Pin_property: /* U1709 */
    /* empty */
|   T_Name '=' T_Identifier ';' Pin_property
|   T_Ppid '=' T_String ';' Pin_property
|   T_XCoord '=' '(' T_Number ',' T_Number ')' ';' Pin_property
|   T_Shape '=' T_Number ';' Pin_property
|   T_PinType '=' T_Identifier ';' Pin_property
|   Pin_Connection Pin_property
;

Pin_Connection:
|   T_Connection '[' T_Number ']' '{' T_Instrument '{' T_String '}' ';' Channel_def '}' Pin_Connection { printf("\tinstrument: %s\n", $8); }
;

Channel_def:
    /* empty */
|   T_SlotChannel '[' T_Number ']' '=' T_Identifier '.' T_Identifier ';' Channel_def { printf("\t%s.%s", $6, $8); }
;

MaxSite_def:
    T_MaxSite '=' T_Number ';'
;

SyntaxVersion:
    T_Head ':' T_Version ';' { printf("version: %s\n", $3); }
;



%%

int main() {
    return yyparse();
}
