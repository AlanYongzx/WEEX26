# data/raw — fichiers Moodle d'origine (lecture seule)

| Fichier | Contenu | Dans Git ? |
|---|---|---|
| `map.xlsx` | sources, population, climat, occupation des sols par maille 70 km | oui |
| `map.png` | carte du pays | oui |
| `MODELISATION_infos_polluants_S6_2025-26.xlsx` | facteurs USEtox par polluant | oui |
| `Vent1AnFinal.mat` | vent U,V un an, pas 3 h | **non** (volumineux, .gitignore) |
| `Vent1MoisFinal.mat` | vent U,V un mois, pas 3 h | **non** (.gitignore) |

Ne jamais modifier ces fichiers. Toute extraction / correction → `data/processed/`.
Noter ici la date de téléchargement si Moodle publie une nouvelle version.
