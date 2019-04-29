%{
#define YYSTYPE char *
#include "y.tab.h"
int cur_line = 1;
void yyerror(const char *msg);
void unrecognized_char(char c);
#define _DUPTEXT {yylval = strdup(yytext);}
%}

/* note \042 is '"' */

OPERATOR        ([-/+*()=,;:.{}\[\]])
NUMBER          (([0-9]+\.)?[0-9]+)
STRING          (\042[^\042\n]*\042)
IDENTIFIER      ([_a-zA-Z][_a-zA-Z0-9]*)
WHITESPACE      ([ \t]*)
SINGLE_COMMENT1     ("//"[^\n]*)
SINGLE_COMMENT2     ("#"[^\n]*)
UN_Head         (Unison)
UN_Version      (SyntaxRevision[0-9]+(\.[0-9]+)*)
UN_AdapterBrd   (__AdapterBoard)
UN_Pin          (__Pin)
UN_PinType      (__PinType)
UN_Name         (__Name)
UN_Resource     (__Resource)
UN_Ppid         (__Ppid)
UN_XCoord       (__XCoord)
UN_Shape        (__Shape)
UN_Connection   (__Connection)
UN_Instrument   (__Instrument)
UN_SlotChannel  (__SlotChannel)
UN_MaxSite      (__MaxSite)

%%
{WHITESPACE}        { /* ignore every whitespace */ }
{SINGLE_COMMENT1}   { /* skip for single line comment */    }
{SINGLE_COMMENT2}   { /* skip for single line comment */    }

{UN_Head}           { return T_Head; }
{UN_Version}        { _DUPTEXT; return T_Version;}
{UN_AdapterBrd}     { return T_AdapterBrd; }
{UN_Pin}            { return T_Pin; }
{UN_PinType}        { return T_PinType; }
{UN_Name}           { return T_Name; }
{UN_Resource}       { return T_Resource; }
{UN_Ppid}           { return T_Ppid; }
{UN_XCoord}         { return T_XCoord; }
{UN_Shape}          { return T_Shape; }
{UN_Connection}     { return T_Connection; }
{UN_Instrument}     { return T_Instrument; }
{UN_SlotChannel}    { return T_SlotChannel; }
{UN_MaxSite}        { return T_MaxSite; }

{OPERATOR}      { return yytext[0]; }
"int"           { return T_Int; }
"print"         { return T_Print; }

{NUMBER}        { _DUPTEXT; return T_Number; }
{STRING}        { _DUPTEXT; return T_String; }
{IDENTIFIER}    { _DUPTEXT; return T_Identifier; }

\n              { cur_line++; }
.               { unrecognized_char(yytext[0]); }
%%

int yywrap(void) {
    return 1;
}

void unrecognized_char(char c) {
    char buf[32] = "Unrecognized character: ?";
    buf[24] = c;
    yyerror(buf);
}

void yyerror(const char *msg) {
    printf("Error at line %d:\n\t%s\n", cur_line, msg);
    exit(-1);
}
