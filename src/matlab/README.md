# src/matlab — code de développement

- Ici on peut travailler en plusieurs fichiers (fonctions, tests).
- Le livrable final doit être **un seul `.m`** dans `deliverables/.../` : fonctions locales en fin de script (Matlab ≥ R2016b).
- Paramètres regroupés en tête (section 1), avec unité et source en commentaire.
- Lecture : `readtable('map.xlsx','VariableNamingRule','preserve')` (noms de colonnes avec °, ²).
- Tests minimum avant remise : bilan de masse fermé, concentrations ≥ 0, concentration source ≈ modèle boîte.

## Fichiers

| Fichier | Rôle |
|---|---|
| `b4_schema_model.m` | v04 courante, modèle schéma-bloc complet, 23 auto-tests ; écrit dans `src/matlab/results/` (ignoré par Git) |
| `archive/b4_schema_model_v02.m` | v02, conservée pour traçabilité (log `results/logs/b4_schema_matlab_run_20261117_v02.txt`) |

Quand une sortie doit être partagée : la copier dans `results/tables/` ou `results/figures/` à la racine et l'indiquer dans le README principal.
