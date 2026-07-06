# Note d’optimisation des coûts — NordCloud
 
Les optimisations de coûts appliquées s’appuient sur l’audit réalisé en Salle 1.
 
## Rightsizing
 
Les ressources surdimensionnées doivent être réduites pour correspondre à leur usage réel.
Exemple : une instance avec beaucoup de vCPU mais très peu de CPU utilisé doit être redimensionnée.
 
## Extinction programmée
 
Les environnements de test ou de recette ne doivent pas tourner inutilement 24h/24.
Une planification d’arrêt/démarrage permet de réduire les coûts.
 
## Tags
 
Toutes les ressources doivent être taguées avec au minimum :
 
- projet ;
- environnement ;
- propriétaire ;
- coût ou centre de coût.
 
## Cycle de vie du stockage
 
Les données froides ou anciennes doivent être déplacées vers un stockage moins coûteux.
 
## Ressources conservées
 
Les ressources correctement dimensionnées, taguées et utilisées en continu ne nécessitent pas d’action.