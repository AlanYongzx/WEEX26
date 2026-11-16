# WEEX DEPOL S7 2026-27 — Groupe B4 (Effergie)

Dépôt de travail du groupe B4 : données, code Matlab, résultats et livrables.

| | |
|---|---|
| Commanditaire | Effergie — N+1 : Céline Besançon |
| Site d'émission (phase 1) | `id_grid = 32_27`, Bantania, *Industrial and commercial port* (partagé avec B2, B6) |
| Polluants (phase 1) | PM10 : 1,09·10⁵ kg/an ; COVNM : 3,28·10⁵ kg/an |
| Phase 1 | lundi 8:00 → mercredi 8:30 |
| Phase 2 | mercredi → vendredi (débat scientifique éventuel vendredi après-midi) |

## Arborescence

```
WEEX26/
├── data/
│   ├── raw/            # fichiers Moodle d'origine (map.xlsx, infos_polluants...) — NE JAMAIS MODIFIER
│   └── processed/      # données extraites / nettoyées (CSV, MAT)
├── src/
│   ├── matlab/         # code de développement (peut être modulaire)
│   └── python/         # scripts de vérification croisée
├── deliverables/       # versions REMISES sur Moodle, figées
│   ├── L1_0_contact/
│   ├── L1_1_schema_bloc/   # L1_1_B4(_IA).pptx — lundi 17:00
│   ├── L1_2_matlab/        # L1_2_B4(_IA).m   — mercredi 8:30
│   ├── L1_3_oral/          # préparation oral mercredi
│   └── phase2/             # livrables vendredi (Matlab + slides + Excel)
├── results/
│   ├── figures/        # PNG + SVG/PDF
│   ├── tables/         # CSV
│   ├── mat/
│   └── logs/
├── docs/
│   ├── cadrage/        # énoncé, traductions, synthèses
│   ├── notes/          # notes par thème (transport, dépôt, USEtox, chimie...)
│   └── meetings/       # comptes rendus (consultants, réunions d'équipe)
├── references/         # articles, docs USEtox, sources des paramètres
└── ai_usage/           # journal d'utilisation de l'IA (prompts + réponses + modifications)
```

## Règles d'équipe

1. **`data/raw/` est en lecture seule.** On ne modifie jamais un fichier Moodle ; on écrit dans `data/processed/`.
2. **Livrable remis = fichier figé.** Une fois déposé sur Moodle, on le copie dans `deliverables/...` et on crée un tag Git (`L1_1`, `L1_2`, ...). On ne le modifie plus ; une nouvelle version porte `_v02`.
3. **Contrainte Matlab du livrable** : un seul fichier `.m`, qui tourne avec `Run` sur l'ordinateur de l'enseignant, à partir de `map.xlsx` uniquement (fichier vent non fourni → prévoir un repli).
4. **IA** : tout usage (même partiel) → suffixe `_IA` dans le nom du livrable + entrée dans `ai_usage/AI_LOG.md` (outil, prompt, réponse brute, ce qu'on a modifié).
5. **Paramètres** : chaque valeur numérique (H, v_d, K, t_1/2, CF...) a une unité et une source, notée dans `docs/notes/parametres.md`. Une hypothèse sans source est marquée **HYPOTHÈSE**.
6. **Statut des résultats** : distinguer *exécuté sous Matlab* / *vérifié en Python* / *contrôle statique* / *estimation à la main*.
7. **Noms de fichiers** : minuscules, `_`, contenu + méthode + cas, ex. `pm10_concentration_annual_wind_v01.png`.
8. **Fichiers vent** (`Vent1AnFinal.mat`, `Vent1MoisFinal.mat`) : à placer dans `data/raw/` en local, **exclus de Git** (volumineux, disponibles sur Moodle).

## Démarrage rapide

Guide détaillé (avec ou sans Git) : **[CONTRIBUTING.md](CONTRIBUTING.md)**.

```bash
git clone https://github.com/AlanYongzx/WEEX26.git
cd WEEX26
# copier depuis Moodle dans data/raw/ : map.xlsx, MODELISATION_infos_polluants_*.xlsx, Vent1AnFinal.mat
```

Matlab : ouvrir `deliverables/L1_2_matlab/`, y copier `map.xlsx` (et éventuellement le fichier vent), puis `Run`.

## Échéances

| Échéance | Livrable | Statut |
|---|---|---|
| lun. 9:30 | L1_0 — contact | ☐ |
| lun. 17:00 | L1_1 — schéma bloc v1 (.pptx/.odp, blocs éditables) | ☐ |
| mer. 8:30 | L1_2 — Matlab mono-fichier | ☐ |
| mer. 9:00–12:15 | L1_3 — oral au tableau (~17 min) | ☐ |
| ven. | Phase 2 — Matlab + slides + Excel | ☐ |

## Répartition des rôles

| Rôle | Membre | Dossiers principaux |
|---|---|---|
| Données & terme source | | `data/`, `src/matlab/` |
| Transport atmosphérique | | `docs/notes/transport.md` |
| Dépôt & dégradation | | `docs/notes/depot.md` |
| Toxicologie / USEtox, impact santé, partie chimie | | `docs/notes/usetox.md`, `docs/notes/chimie.md` |
| Méthodes numériques & code | | `src/matlab/` |
| Intégration & oral | | `deliverables/L1_3_oral/` |
