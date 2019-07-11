# analyseJSON
A command-line JSON parser and analyser

## Description
analyseJSON allow you to parse a JSON file and throw an error if the file isn't well formatted. 
You can analyse the content of the file in the command line, and search for a specific content.

## Dependencies 
- Yacc
- Lex

## Exemple : 
```bash
~$ ./analyseJSON abacab.json object
? object
{
	"titre_album" : "Abacab",
	"groupe" : {"nom" : "Genesis",
"membres" : ["Peter Gabriel", "Mike Rutherford", "Tony Banks", "Anthony Phillips"]},
	"annee" : 1981,
	"genre" : "Rock"
}
? object["titre_album"]
"Abacab"
? object["groupe"]["nom"]
"Genesis"
? object["annee"]
1981
```

## Installation
Compile the Makefile using cmake :
```
~/analyseJSON$ cmake .
```
Then, use make to compile the executable :
```
~/analyseJSON$ make
```
Or to produce the deb package :
```
~/analyseJSON$ make package
```

# Credit
Nathaniel Hayoun
