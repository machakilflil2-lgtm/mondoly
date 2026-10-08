# mondoly

Patchs Dolibarr maison, appliqués aux instances auto-hébergées (VPS).

## Patches

| Patch | Cible | Objet |
|---|---|---|
| `patches/dolibarr-24-factures-deblocage.patch` | Dolibarr 24.x / 25.x — `core/class/commoninvoice.class.php` | Débloque le retour en brouillon et la suppression des factures clients via l'option cachée `INVOICE_CAN_ALWAYS_BE_REMOVED` |

### dolibarr-24-factures-deblocage

Depuis la v24, le core refuse :

- de repasser en brouillon une facture déjà téléchargée / imprimée (`isEditable()`, code `-6` sur `pos_print_counter`) ;
- de supprimer une facture déjà imprimée (`is_erasable()`, code `-6`) ou qui n'est pas la dernière de la série de numérotation (`is_erasable()`, code `-2`) ;
- et l'option historique `INVOICE_CAN_ALWAYS_BE_REMOVED` (présente jusqu'à la v6, elle levait justement ces règles) n'est plus lue par le code, sans remplacement.

Ce patch **restaure l'option historique sur les gardes actuelles** (factures clients uniquement, factures fournisseurs non touchées) :

- `isEditable()` : `-6` ignoré si l'option est posée ;
- `is_erasable()` : `-6` et `-2` ignorés si l'option est posée.

**Comportement par défaut inchangé** : rien ne change tant que la constante n'est pas posée.

### Activation (indispensable)

Configuration > Divers (Other setup), ou SQL :

```sql
INSERT INTO llx_const (name, entity, value, type, visible, note)
VALUES ('INVOICE_CAN_ALWAYS_BE_REMOVED', 0, '1', 'chaine', 0, 'Deblocage factures clients (mondoly)');
```

`entity` = `0` pour toutes les entités, ou l'ID de l'entité cible.

Gardes qui restent actives : paiement (`-4`), envoyée par e-mail (`-5`), comptabilité (`-1`), LNE (`-7`), situations (`-3`).

Appliqué sur `murbanisme.rentify.ma` (Dolibarr 24.0.1, constante posée) le 2026-10-08.

## Proposition au projet officiel

Le même changement est proposé au dépôt officiel : **[Dolibarr/dolibarr#41499](https://github.com/Dolibarr/dolibarr/pull/41499)** (branche `new-invoice-can-always-be-removed`, cible `develop`).
Tant qu'il n'est pas fusionné, appliquer ce patch après chaque mise à jour via `apply.sh`.

## Application

```bash
./apply.sh /chemin/vers/dolibarr      # racine contenant core/, compta/, htdocs/...
```

Le script :

- sauvegarde le fichier d'origine (`*.bak-mondoly-<horodatage>`) ;
- est idempotent (détection de l'option déjà câblée) ;
- lance `php -l` si PHP est disponible ;
- rappelle de poser la constante `INVOICE_CAN_ALWAYS_BE_REMOVED=1`.

**Après chaque mise à jour de Dolibarr, le patch saute : le ré-appliquer** (ou attendre la fusion upstream). Pour revenir en arrière : restaurer la sauvegarde `.bak-mondoly-*` ou `patch -R -p1`.

## Avertissements

- Supprimer une facture en milieu de série laisse des trous dans la numérotation (sans impact technique).
- Modifier ou supprimer une facture déjà transmise au client est un choix métier : Dolibarr recommande une facture d'avoir.
- Patch testé sur Dolibarr 24.0.1 ; fourni tel quel, sans garantie.
