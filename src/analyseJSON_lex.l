  /* analyseJSON.l analyseur lexical. */
%{
#include "analyseJSON.h"
%}
  int lineno = 1;

  // Options lex pour ne pas recevoir les Warnings de non-utilisation
%option nounput 
%option noinput
%%
"-"?[0-9]+		 { yylval.o.type = ENTIER ; // On récupère le nombre et on le stocke dans l'objet
				   yylval.o.contenu = malloc(sizeof(int)); 
				   * (int*) yylval.o.contenu = atoi(yytext) ; 
				   return YNUM;	}

[[\]{},:]		 { return yytext[0]; }

true|false		 { yylval.o.type = BOOL ;
				   yylval.o.contenu = malloc(sizeof(int));
				   * (int*) yylval.o.contenu = 0 ;
				   if(strcmp(yytext, "false"))
				   		* (int*) yylval.o.contenu = 1 ; 
				   return YBOOL; }

null			{ yylval.o.type = JNULL ;
				  yylval.o.contenu = NULL;
				  return YNULL ; }

\"[^"]*\"        { yylval.o.type = CHAINE ; // Si c'est une chaîne de caractère, on la copie dans contenu
				   yylval.o.contenu = malloc(sizeof(char)*strlen(yytext)) ;
				   strncpy(yylval.o.contenu, yytext, strlen(yytext)-1) ; // On coupe le dernier guillemet
				   yylval.o.contenu++ ;									 // Et le premier
				   return YSTRING; }

[ \t]			;
\n			lineno += 1;
.			{ fprintf(stderr, "Erreur yylex ligne %i: (%c)\n", lineno, yytext[0]); exit(1) ;}
%%

int yywrap(){ return 1; }
