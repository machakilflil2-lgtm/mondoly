#!/usr/bin/env bash
# Applique un patch mondoly à une instance Dolibarr.
# Usage : ./apply.sh <racine_dolibarr> [fichier.patch]
set -euo pipefail

ROOT="${1:?Usage: ./apply.sh <racine_dolibarr> [fichier.patch]}"
PATCH_FILE="${2:-$(cd "$(dirname "$0")" && pwd)/patches/dolibarr-24-factures-deblocage.patch}"
TARGET="core/class/commoninvoice.class.php"

cd "$ROOT"
[ -f "$TARGET" ] || { echo "Introuvable : $ROOT/$TARGET"; exit 1; }

if grep -q "INVOICE_CAN_ALWAYS_BE_REMOVED" "$TARGET"; then
	echo "Déjà appliqué ($TARGET)."
else
	cp -a "$TARGET" "$TARGET.bak-mondoly-$(date +%Y%m%d%H%M%S)"
	patch -p1 --forward < "$PATCH_FILE"
	if command -v php >/dev/null; then php -l "$TARGET"; fi
fi

echo
echo "IMPORTANT : poser la constante INVOICE_CAN_ALWAYS_BE_REMOVED=1 (Configuration > Divers) pour activer le déblocage."
echo "Si opcache/php-fpm est actif : systemctl reload php8.x-fpm (adapter la version)"
