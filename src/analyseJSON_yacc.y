
%{
#include "analyseJSON.h"

objet racine ;          // L'Objet à la racine du fichier JSON 
int indentation = 0 ;   // À quelle sous-couche sommes-nous ?
%}

// Type d'éléments lexicaux
%union {
  objet o ;			/* Listes et dict*/
  elemListe el ;
  elemDict ed ;
};

%token <o> YNUM
%token <o> YBOOL
%token <o> YNULL
%token <o> YSTRING
%type <o> liste
%type <o> dict
%type <o> objet
%type <el> suiteObjets
%type <ed> paire
%type <ed> suitePaires

%%
file : objet {racine = $1 ;}

objet : YNUM | YBOOL | YNULL | YSTRING
| liste
| dict

liste : '[' suiteObjets ']' {$$.type = LISTE ; 
                             $$.contenu = malloc(sizeof(struct ElemListe)) ; 
                             * (elemListe*) $$.contenu = $2 ;} 
| '[' ']' {$$.type = LISTE ; $$.contenu = NULL ; } // Liste vide

// typedef struct ElemListe {  objet* element ;  struct ElemListe* next ; } elemListe;
suiteObjets : objet { $$.element = malloc(sizeof(struct Objet)) ; // Dernier élément de la liste...
                      *$$.element = $1 ; 
                      $$.next = NULL ; }                          // ...ne pointe sur rien

| objet ',' suiteObjets { $$.element = malloc(sizeof(struct Objet)) ; 
                          *$$.element = $1 ; // On récupère la valeur de l'élément précedent         
                          $$.next = malloc(sizeof(struct ElemListe)) ;
                          (*$$.next) = $3 ;  // Et on lie la prochaine valeur
                        }


dict : '{' suitePaires '}' {$$.type = DICT ; 
                            $$.contenu = malloc(sizeof(struct ElemDict)) ;
                            * (elemDict*) $$.contenu = $2 ;}
| '{' '}' {$$.type = DICT ; $$.contenu = NULL ;}

// typedef struct ElemDict { char* key ; objet* value ;  struct ElemDict* next ;} elemDict ;
suitePaires : paire { $$ = $1 ; $$.next = NULL ;} // Dernière paire de la liste
| paire ',' suitePaires {
  $$ = $1 ;
  $$.next = malloc(sizeof(struct ElemDict)) ; // Et on lie la prochaine valeur
  (*$$.next) = $3 ;
}

paire : YSTRING ':' objet {
  $$.key = strdup($1.contenu) ;
  $$.value = malloc(sizeof(struct Objet)) ;
  *($$.value) = $3 ;
}
%%

int main(int argc, char ** argl){
  if (argc < 3) {
    printf("Usage : %s JSONfile object_Name\n", argl[0]);
    return(1) ;
  }

  // On sauvegarde l'entrée standard avant l'appel à freopen pour le restaurer plus tard
  int fd_stdin ; 
  fd_stdin = dup(fileno(stdin)) ;

  // On utilise le fichier donné en argument comme entrée standard pour qu'il soit parsé par yyparse
  if( freopen(argl[1], "r", stdin) == NULL ){
    printf("Erreur : Impossible d'ouvrir le fichier %s\n", argl[1]);
    exit(1) ;
  }

  yyparse();

  dup2(fd_stdin, fileno(stdin)) ;                     // On restaure l'entrée standard
  boucleRequetes(racine, strdup(argl[2])) ;
  return 0 ;
}

void boucleRequetes(objet racine, char * objName){
  objet obj ;
  objet* obj_p ;
  char * requete = malloc(sizeof(char)*MAX_SIZE) ;  char c ;
  req :
  while(printf("? ") && !fflush(stdout) && fgets(requete, MAX_SIZE, stdin)){
    obj = racine ; // reset 
    // Rien
    if (*requete == '\n') continue ;

    // Si l'utilisateur n'écrit pas le bon nom d'objet, erreur
    if(strncmp(requete, objName, strlen(objName)) || ((c = requete[strlen(objName)]) != '\n' && c != '[')){
      printf("Erreur : L'objet JSON se nomme %s\n", objName);
      continue ;
    }
    requete = &requete[strlen(objName)] ; // On passe aux choses sérieuses
    while(*requete == '['){
      requete++;
      int i = 0 ;
      while(*(requete+i) != ']' && i < MAX_SIZE) i++ ;
      if (i == MAX_SIZE) {printf("Requête mal formée\n") ; goto req ;}
      char * index = strndup(requete, i) ;
      requete += i + 1; // On passe au '[' d'après 
      if (isalpha(*index)) {
        printf("Erreur : N'oubliez pas les guillemets autour de la clé : \"%s\"\n", index) ;
        goto req ;
      }

      // ** Accès liste : objet[55] **
      if (isdigit(*index)){
        int intIndex = atoi(index) ;
        if (obj.type != LISTE){
          printf("Erreur : Tentative d'accès par index à autre chose qu'une liste\n") ;
          goto req ;
        }
        obj_p = findInList(* (elemListe*) obj.contenu, intIndex) ;
        if (obj_p == NULL) {
          printf("Erreur : List Index out of range (%i)\n", intIndex) ;
          goto req ;
        }
        obj = *obj_p ;
      }

      // ** Accès Dictionnaire : objet["SEPT"] **
      else if(*index == '"'){
        if (obj.type != DICT){
          printf("Erreur : Tentative d'accès par clé à autre chose qu'un dictionnaire\n") ;
          goto req ;
        }
        if (index[strlen(index)-1] != '"') {printf("Requête mal formée\n") ; goto req ;}
        index++;
        index = strndup(index, strlen(index)-1) ; // On supprime les guillemets de la fin
        obj_p = findInDict(* (elemDict*) obj.contenu, index) ;
        if (obj_p == NULL) {
          printf("Erreur : Key \"%s\" not found\n", index) ;
          goto req ;
        }        
        obj = *obj_p ;
      }
    }
    affiche(obj) ;
    printf("\n") ;
  } 
  printf("\nBye\n");
  return ;
}

objet * findInList(elemListe e, int index){
  int i ;
  for(i = 0; i < index && (e.next != NULL) ; i++)
    e = *e.next ;
  if (i < index) return NULL ; // On n'a pas atteint l'index, et la liste est finie
  return e.element ;
}

objet * findInDict(elemDict e, char * cle){
  while(strcmp(e.key, cle) && e.next != NULL) e = *e.next ;
  if(strcmp(e.key, cle)) return NULL ;
  return e.value ; 
}

void affiche(objet o){
  switch(o.type){
      case(JNULL) : printf("null"); return ;
      case(BOOL) : 
        if (*(int*) o.contenu) printf("true"); 
        else printf("false") ; 
        return ;
      case(ENTIER) : printf("%i", *(int*) o.contenu); return ;
      case(CHAINE) : printf("\"%s\"", (char*) o.contenu); return ;
      case(LISTE) :
        if (o.contenu != NULL) afficheListe(*(elemListe*) o.contenu) ; 
        else printf("[]"); // Liste vide
        return ;
      case(DICT) : indentation++; afficheDict(*(elemDict*) o.contenu) ; return ;
  }
}

// Affiche une liste
void afficheListe(elemListe e){
  printf("[") ;
  affiche(*e.element);
  while( e.next != NULL){
    printf(", ");
    e = *e.next ;
    affiche(*e.element) ;
  }
  printf("]");
}

// Affiche les paires d'un dictionnaire
void afficheDict(elemDict e){
  printf("{");
  if(indentation <= 1) printf("\n\t");
  printf("\"%s\" : ", e.key) ;
  affiche(*e.value) ;
  while( e.next != NULL){
    printf(",\n");
    if(indentation <= 1) printf("\t");
    e = *e.next ;
    printf("\"%s\" : ", e.key) ;
    affiche(*e.value) ;
  }
  if(indentation <= 1) printf("\n");
  printf("}");
  if (indentation) indentation-- ;
}

# include "lex.yy.c"

void yyerror(char * message){
  extern int lineno;
  extern char * yytext;

  fprintf(stderr, "%d: %s at %s (yyerror)\n", lineno, message, yytext);
}
