# Comment contribuer — Groupe B4

Deux façons de travailler, au choix. Les deux aboutissent au même dépôt.

## A. Sans Git (navigateur uniquement)

**Lire / télécharger** : ouvrir le dossier sur GitHub → cliquer sur le fichier → *Download raw file*.
Tout le dépôt : bouton vert **Code → Download ZIP**.
Une version remise (L1_1, L1_2...) : onglet **Releases**.

**Ajouter un fichier** : aller dans le bon dossier → **Add file → Upload files** → glisser le fichier →
en bas, écrire un message (voir « Messages de commit ») → **Commit directly to the `main` branch**.

**Modifier un `.md`** : ouvrir le fichier → icône crayon → modifier → *Commit changes*.

## B. Avec Git

```bash
git clone https://github.com/AlanYongzx/WEEX26.git
cd WEEX26
git pull                      # TOUJOURS avant de commencer
# ... travailler ...
git add <fichiers>
git commit -m "transport: schema amont + CFL"
git pull --rebase             # recuperer le travail des autres
git push
```

Pour un changement important du code (`src/matlab/`, livrables) : créer une branche
(`git switch -c transport-cfl`), pousser, puis ouvrir une **Pull Request** sur GitHub.

## Où mettre quoi

| Je produis… | Dossier |
|---|---|
| un fichier Moodle d'origine | `data/raw/` (jamais modifié ensuite) |
| un CSV / MAT extrait ou nettoyé | `data/processed/` |
| du code Matlab en cours | `src/matlab/` |
| une figure / un tableau de résultats | `results/figures/`, `results/tables/` |
| des notes sur un thème | `docs/notes/<theme>.md` |
| le compte rendu d'un consultant | `docs/meetings/AAAAMMJJ_<nom>.md` |
| un article / une doc | `references/` |
| le fichier remis sur Moodle | `deliverables/<livrable>/` |

## Messages de commit

`<theme>: <ce qui change>` — ex. `usetox: CF PM10 corrige`, `L1_2: version remise`, `donnees: ajout map.xlsx`.

## Remise d'un livrable sur Moodle

1. Copier le fichier **exactement remis** dans `deliverables/<livrable>/` (nom imposé : `L1_2_B4_IA.m`, etc.).
2. Commit `L1_2: version remise`.
3. Créer le tag : `git tag L1_2 && git push --tags`
   (ou sur GitHub : **Releases → Draft a new release → Choose a tag → `L1_2`**).
4. La Release avec l'archive est générée automatiquement.

## Contrôles automatiques (onglet **Actions**)

À chaque envoi, GitHub vérifie :
- aucun fichier de `data/raw/` modifié ou supprimé ;
- pas de fichier vent `.mat`, pas de fichier > 50 MB ;
- noms des livrables conformes (`L1_1_B4(_IA).pptx/.odp`, `L1_2_B4(_IA).m`) ;
- livrable Matlab : signale `addpath`/`run` (doit être mono-fichier) et caractères non ASCII.

Une croix rouge ✗ = lire le message d'erreur dans **Actions**, corriger, renvoyer.

## Tâches et questions

Onglet **Issues** → *New issue* → modèle **Tâche** ou **Question pour un consultant**.
S'assigner la tâche ; fermer l'issue quand c'est fini.
