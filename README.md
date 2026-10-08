# mondoly

Patchs Dolibarr maison, appliqués aux instances auto-hébergées (VPS).

## Patches

| Patch | Cible | Objet |
|---|---|---|
| `patches/dolibarr-24-factures-deblocage.patch` | Dolibarr 24.x — `core/class/commoninvoice.class.php` | Débloque le retour en brouillon et la suppression des factures clients |

### dolibarr-24-factures-deblocage

Depuis la v24, le core refuse :

- de repasser en brouillon une facture déjà téléchargée / imprimée (`isEditable()`, garde `-6` sur `pos_print_counter`) ;
- de supprimer une facture déjà imprimée (`is_erasable()`, garde `-6`) ou qui n'est pas la dernière de la série (`is_erasable()`, garde `-2`, `getNextNumRef`) ;
- l'ancienne option `INVOICE_CAN_ALWAYS_BE_REMOVED` qui couvrait ces cas **n'existe plus** en v24 (constante ignorée, aucun réglage équivalent).

Ce patch neutralise ces trois gardes pour les **factures clients** uniquement (factures fournisseurs non touchées).
Restent actives : paiement enregistré (`-4`), envoi par e-mail (`-5`), comptabilité/ventilation (`-1`), versions LNE (`-7`), situations (`-3`).

Appliqué pour la première fois sur `murbanisme.rentify.ma` (Dolibarr 24.0.1) le 2026-10-08.

## Application

```bash
./apply.sh /chemin/vers/dolibarr      # racine contenant core/, compta/, htdocs/...
```

Le script :

- sauvegarde le fichier d'origine (`*.bak-mondoly-<horodatage>`) ;
- est idempotent (détection du marqueur `PATCH MURBANISME-RENT`) ;
- lance `php -l` si PHP est disponible.

**Après chaque mise à jour de Dolibarr, le patch saute : le ré-appliquer.** Pour revenir en arrière, restaurer la sauvegarde `.bak-mondoly-*` (ou `patch -R -p1 < patches/...`).

## Avertissements

- Supprimer une facture en milieu de série laisse des trous dans la numérotation (sans impact technique).
- Modifier ou supprimer une facture déjà transmise au client est un choix métier : Dolibarr recommande une facture d'avoir.
- Patch fourni tel quel, sans garantie ; testé sur Dolibarr 24.0.1.
