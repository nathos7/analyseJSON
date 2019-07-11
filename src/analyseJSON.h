#include <stdio.h>
#include <stdlib.h>
#include <ctype.h> 
#include <string.h>
#include <unistd.h>

#ifndef MAX_SIZE
#define MAX_SIZE 5000 // Taille max de la requête

enum {JNULL, BOOL, ENTIER, CHAINE, LISTE, DICT} ;

typedef struct Objet {
	int type ;
	void* contenu ;
} objet ;

typedef struct ElemListe
{
	objet* element ;
	struct ElemListe* next ;
} elemListe;

typedef struct ElemDict {
	char* key ;
	objet* value ;
	struct ElemDict* next ;
} elemDict ;

void yyerror(char * message) ;
int yylex() ;

void affiche(objet o) ;
void afficheListe(elemListe e) ; 
void afficheDict(elemDict e) ;
objet * findInList(elemListe e, int index) ;
objet * findInDict(elemDict e, char * cle) ;
void boucleRequetes(objet racine, char * objName) ;
#endif