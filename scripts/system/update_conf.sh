#!/usr/bin/env bash
# Met à jour la config en re-clonant dans un dossier temporaire
# puis en copiant les fichiers dans ~/afs/.confs/

source "$HOME/afs/.confs/scripts/globals.sh"

TMP_DIR="$HOME/config_from_yinpi_tmp"

printf "${BLUE}::${NC} %-42s" "Téléchargement de la dernière version..."
rm -rf "$TMP_DIR"
if git clone -b "$BRANCH" "$REPO_CONFS" "$TMP_DIR" > /dev/null 2>&1; then
    printf "[${GREEN}OK${NC}]\n"
else
    printf "[${RED}KO${NC}]\n"
    exit 1
fi

printf "${BLUE}::${NC} %-42s" "Déploiement dans ~/afs/.confs/..."

ITEMS=(Config scripts version install.sh check.sh installer.sh clean.sh)
BACKUP_DIR="$CONFS/.update_backup_$$"
mkdir -p "$BACKUP_DIR"

# Sauvegarde des fichiers existants avant toute modification
for item in "${ITEMS[@]}"; do
    [ -e "$CONFS/$item" ] && mv "$CONFS/$item" "$BACKUP_DIR/"
done

# Copie des nouveaux fichiers
copy_ok=true
cp -r "$TMP_DIR/Config"  "$CONFS/"  || copy_ok=false
cp -r "$TMP_DIR/scripts" "$CONFS/"  || copy_ok=false
cp    "$TMP_DIR/version"     "$CONFS/" || copy_ok=false
cp    "$TMP_DIR/install.sh"  "$CONFS/" || copy_ok=false
cp    "$TMP_DIR/check.sh"    "$CONFS/" || copy_ok=false
[ -f "$TMP_DIR/installer.sh" ] && { cp "$TMP_DIR/installer.sh" "$CONFS/" || copy_ok=false; }
[ -f "$TMP_DIR/clean.sh"     ] && { cp "$TMP_DIR/clean.sh"     "$CONFS/" || copy_ok=false; }

if $copy_ok; then
    chmod +x "$CONFS/install.sh" "$CONFS/check.sh"
    [ -f "$CONFS/installer.sh" ] && chmod +x "$CONFS/installer.sh"
    [ -f "$CONFS/clean.sh"     ] && chmod +x "$CONFS/clean.sh"
    find "$CONFS/scripts" -name "*.sh" -exec chmod +x {} \;
    rm -rf "$BACKUP_DIR"
    printf "[${GREEN}OK${NC}]\n"
else
    # Restauration depuis la sauvegarde
    for item in "${ITEMS[@]}"; do
        [ -e "$BACKUP_DIR/$item" ] && mv "$BACKUP_DIR/$item" "$CONFS/"
    done
    rm -rf "$BACKUP_DIR"
    printf "[${RED}KO (restauré depuis backup)${NC}]\n"
    rm -rf "$TMP_DIR"
    exit 1
fi

printf "${BLUE}::${NC} %-42s" "Nettoyage..."
rm -rf "$TMP_DIR"
printf "[${GREEN}OK${NC}]\n"

printf "${GREEN}Config mise à jour avec succès.${NC}\n"
