# Note de sécurité — NordCloud
 
## Security Groups
 
L’architecture utilise des Security Groups séparés pour chaque tier :
 
- SG Frontend :
  - Autorise HTTP/HTTPS depuis Internet.
  - N’autorise pas l’accès direct à la base de données.
 
- SG Métier :
  - Autorise uniquement le trafic venant du SG Frontend.
  - Communique avec le tier données sur le port de la base.
 
- SG Data :
  - Autorise uniquement le trafic venant du SG Métier.
  - Refuse tout accès direct depuis Internet.
 
## IAM
 
Les droits IAM sont limités au strict nécessaire.
Chaque ressource ou service dispose uniquement des permissions dont il a besoin.
 
## Chiffrement
 
Les volumes sensibles et les données de la base sont chiffrés au repos.
Le chiffrement utilisé est le sha256, cela permet de réduire le risque en cas d’accès non autorisé au stockage.
 
## Justification
 
Cette organisation respecte le principe de défense en profondeur :
chaque tier est isolé, les flux sont contrôlés, et les accès sont limités.