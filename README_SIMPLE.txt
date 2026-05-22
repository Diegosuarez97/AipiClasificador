PROJECTE AIPI - VERSIO SIMPLE

Com executar:

1. Obrir MATLAB.
2. Posar com a Current Folder aquesta carpeta:
   entrega_simple
3. Escriure a la consola:

   projecte_aipi_simple

Que fa:

- Entrena tres classes: Oset, JocDS i Cullera.
- Utilitza regionprops per calcular descriptors de forma.
- Classifica les imatges de test.
- Dibuixa bounding box, centroide i nom de l'objecte.
- Guarda tambe la imatge binaritzada que s'ha utilitzat.
- En el cas dels ossets, intenta indicar el color de l'objecte.
- Genera alguns grafics senzills per a la memoria.
- Guarda els resultats a la carpeta resultats.

Descriptors utilitzats:

- Eccentricity
- Extent
- Solidity
- Relacio entre eix major i eix menor
- Circularitat

Extra de color:

Per als ossets es miren els pixels amb mes saturacio dins de la mascara.
Si hi ha poc color clar, es considera transparent. Si no, el resultat es
passa a un nom senzill: vermell, taronja, groc o verd.

Grafics:

El fitxer funcions/fer_grafics_simple.m crea grafics de descriptors, recompte de
deteccions i colors dels ossets. El programa principal el crida al final.

Carpetes importants:

- data: imatges d'entrenament i test.
- projecte_aipi_simple.m: programa principal de la practica.
- funcions: funcions auxiliars del projecte.
- resultats: es crea automaticament quan s'executa el programa.
  Dins hi ha imatges_anotades, binaritzades i resum.csv.

Nota:

Aquesta versio esta feta expressament de forma mes directa i senzilla.
Les funcions estan separades perque el programa principal sigui facil de
llegir i d'explicar en una defensa de practica.
