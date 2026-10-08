#!/usr/bin/env bash
# Applique un patch mondoly à une instance Dolibarr.
# Usage : ./apply.sh <racine_dolibarr> [fichier.patch]
set -euo pipefail

ROOT="${1:?Usage: ./apply.sh <racine_dolibarr> [fichier.patch]}"
PATCH_FILE="${2:-$(cd "$(dirname "$0")" && pwd)/patches/dolibarr-24-factures-deblocage.patch}"
TARGET="core/class/commoninvoice.class.php"

cd "$ROOT"
[ -f "$TARGET" ] || { echo "Introuvable : $ROOT/$TARGET"; exit 1; }

if grep -q "PATCH MURBANISME-RENT" "$TARGET"; then
	echo "Déjà appliqué ($TARGET)."
	exit 0
fi

cp -a "$TARGET" "$TARGET.bak-mondoly-$(date +%Y%m%d%H%M%S)"
patch -p1 --forward < "$PATCH_FILE"

command -v php >/dev/null && php -l "$TARGET"

echo
echo "OK. Si opcache/php-fpm est actif : systemctl reload php8.x-fpm (adapter la version)"
