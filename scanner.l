%{
#define YYSTYPE char *
#include "y.tab.h"
int cur_line = 1;
void yyerror(const char *msg);
void unrecognized_char(char c);
#define _DUPTEXT {yylval = strdup(yytext);}
%}

%x IN_COMMENT

/* note \042 is '"' */

OPERATOR        ([-/+*()=,;:.{}\[\]])
NUMBER          (([0-9]+\.)?[0-9]+)
STRING          (\042[^\042\n]*\042)
IDENTIFIER      ([_a-zA-Z][_a-zA-Z0-9]*)
WHITESPACE      ([ \t]*)
SINGLE_COMMENT1 ("//"[^\n]*)
SINGLE_COMMENT2 ("#"[^\n]*)
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

UN_PinGroup     (__PinGroup)
UN_PinTypeDef   (__PinType\s+\w+\s*{)
UN_Expression   (__Expression)
UN_Group        (__Group)
UN_Type         (__Type)
UN_String       (__String)
UN_ControlFlags (__ControlFlags)

%%
{WHITESPACE}        { /* ignore every whitespace */ }
{SINGLE_COMMENT1}   { /* skip for single line comment */    }
{SINGLE_COMMENT2}   { /* skip for single line comment */    }

<INITIAL>{
"/*"              BEGIN(IN_COMMENT);
}
<IN_COMMENT>{
"*/"      BEGIN(INITIAL);
[^*\n]+   // eat comment in chunks
"*"       // eat the lone star
\n        yylineno++;
}

{UN_Head}           { return UN_Head; }
{UN_Version}        { _DUPTEXT; return UN_Version;}
{UN_AdapterBrd}     { return UN_AdapterBrd; }
{UN_Pin}            { return UN_Pin; }
{UN_PinType}        { return UN_PinType; }
{UN_Name}           { return UN_Name; }
{UN_Resource}       { return UN_Resource; }
{UN_Ppid}           { return UN_Ppid; }
{UN_XCoord}         { return UN_XCoord; }
{UN_Shape}          { return UN_Shape; }
{UN_Connection}     { return UN_Connection; }
{UN_Instrument}     { return UN_Instrument; }
{UN_SlotChannel}    { return UN_SlotChannel; }
{UN_MaxSite}        { return UN_MaxSite; }

{UN_PinGroup}       { return UN_PinGroup; }
{UN_Expression}     { return UN_Expression; }
{UN_Group}          { return UN_Group; }
{UN_Type}           { return UN_Type; }
{UN_String}         { return UN_String; }


{OPERATOR}      { return yytext[0]; }

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
