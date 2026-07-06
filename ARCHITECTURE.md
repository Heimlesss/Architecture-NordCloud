# Architecture 3-tiers NordCloud

## Schéma

```
                         Internet
                            │
                     80/443 │ 22 (my_ip uniquement)
                            ▼
                  ┌───────────────────┐
                  │  TIER PRÉSENTATION │  sg-presentation
                  │   front-<author>   │
                  └─────────┬─────────┘
                            │ app_port (8080) + 22
                            │  (uniquement depuis sg-presentation)
                            ▼
                  ┌───────────────────┐
                  │  TIER APPLICATION  │  sg-application
                  │  app-<author>-N    │
                  └─────────┬─────────┘
                            │ db_port (5432) + 22
                            │  (uniquement depuis sg-application)
                            ▼
                  ┌───────────────────┐
                  │   TIER DONNÉES     │  sg-database
                  │    db-<author>     │
                  │  + volume chiffré  │
                  └───────────────────┘
```

Les 3 instances partagent le même réseau public OVH (`Ext-Net`). L'isolation
entre tiers est assurée uniquement par les **security groups** (pas de réseau
privé/vRack) : c'est le strict minimum pour satisfaire "tier données isolé du
tier présentation, avec accès restreint" sans dépendance à une région
compatible vRack ni gestion de subnet.

## Security Groups en couches

Chaque tier n'autorise en entrée que le tier immédiatement au-dessus de lui,
via `remote_group_id` (jamais de `0.0.0.0/0` en dehors du tier présentation).
Voir [security-groups.tf](security-groups.tf).

| Tier         | Source autorisée    | Ports                 |
|--------------|----------------------|-----------------------|
| Présentation | `0.0.0.0/0`          | 80, 443               |
| Présentation | `var.my_ip` (admin)  | 22                    |
| Application  | `sg-presentation`    | `app_port` (8080), 22 |
| Données      | `sg-application`     | `db_port` (5432), 22  |

L'accès SSH se fait en cascade (admin → front → app → db) : aucun tier
interne n'est joignable directement depuis Internet ni depuis l'IP admin.

## IAM à privilège minimal

[iam.tf](iam.tf) définit une `ovh_iam_policy` scopée :
- **resources** : uniquement l'URN de ce projet (`ovh_project_id`), pas de
  portée compte.
- **allow** : uniquement les actions `get`/`list`/`create` du catalogue
  `cloudProject` touchant `instance`, `network` ou `volume`, dérivées de
  `data.ovh_iam_reference_actions` (pas de `delete`/`update`).

## Chiffrement des volumes sensibles

[storage.tf](storage.tf) attache au tier données un volume Cinder distinct du
disque de boot (`db_volume_type`, chiffré si le catalogue du projet OVH
propose un type de volume chiffré ; sinon à compléter par du LUKS au niveau OS
avant toute donnée réelle).

## Coûts / conformité

Aucune correction spécifique des Salles 1 et 2 n'ayant été fournie, bonnes
pratiques par défaut : flavors minimales (`d2-2`), une seule région, pas
d'IP flottante supplémentaire, tier application scalable via `count`
(défaut = 1).

## Statut

`terraform validate` passe sur l'ensemble de la configuration. Aucun
`terraform plan`/`apply` n'a été lancé (nécessite des identifiants OVH réels
et confirmation explicite).
