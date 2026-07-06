# IAM à privilège minimal — NordCloud

Ce document explique en langage simple ce qu'on met en place pour le volet
IAM du brief, à montrer à l'intervenant.

## Le problème qu'on évite

Normalement, pour déployer avec Terraform, on utilise des clés API OVH qui
donnent accès à **tout le compte**. Si ces clés fuitent, on peut tout casser,
sur tous les projets.

## Ce qu'on fait à la place

Dans [main.tf](main.tf), on crée une **policy IAM** (`ovh_iam_policy`) qui dit :

> "Cette identité a le droit de faire *seulement* ça : lire et créer des
> instances, des réseaux et des volumes — et *seulement* sur ce projet-là."

Concrètement :
- **`resources`** : limite la policy à l'URN de notre projet uniquement (pas
  aux autres projets du compte OVH).
- **`allow`** : une liste courte de 5 actions (`get`/`create` sur
  instance/network/volume). Pas de suppression, pas de modification en dehors
  de Terraform, pas d'accès aux autres services OVH.
- **`identities`** : une seule identité désignée, pas tout le monde.

C'est ça, le "privilège minimal" : le strict nécessaire, rien de plus.

## État actuel : cette partie est désactivée par défaut

Tant qu'on ne connaît pas l'identité à qui donner ces droits, la ressource ne
se crée pas (`count = 0` dans le code). Ça permet de tester le reste du
projet (les 3 tiers, les security groups, le volume chiffré) sans être
bloqué en attendant cette information.

## Ce qu'il manque pour l'activer

Une seule chose : **l'identité OVH** à qui donner cette policy. On n'a pas
accès à la plateforme nous-mêmes (c'est l'intervenant qui gère le compte), il
faut donc lui demander.

## Question à poser à l'intervenant

> "Quelle identité (ton compte, ou un utilisateur dédié que tu nous crées)
> doit recevoir cette policy de déploiement à privilège minimal ?"

Une fois la réponse obtenue, on la met dans `terraform.tfvars` (fichier non
versionné) et la policy se crée au prochain `terraform apply`.
