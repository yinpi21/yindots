#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#   clean.sh — Désinstallation de la config EPITA
#
#   Usage local :
#     bash ~/afs/.confs/clean.sh
#
#   Usage one-liner (curl) :
#     bash <(curl -Ls https://raw.githubusercontent.com/yinpi21/yindots/main/clean.sh)
#
#   Inverse install.sh :
#     - Supprime les symlinks ~/.config/[app] créés par install.sh
#     - Supprime les dotfiles symlinks (~/.bashrc etc.)
#     - Restaure les sauvegardes .bak si elles existent
#     - Ne touche PAS aux fichiers qui ne sont pas des symlinks vers ce repo
# ══════════════════════════════════════════════════════════════════════════════

set -e

# Quand lancé via curl (pas de fichier), on se base sur ~/afs/.confs
# Quand lancé depuis le repo, on utilise le chemin du script
if [ -n "$BASH_SOURCE" ] && [ "$BASH_SOURCE" != "$0" ]; then
    # sourcé — ne devrait pas arriver
    CONFS="$HOME/afs/.confs"
elif [ "$0" = "bash" ] || [ "$0" = "sh" ]; then
    # curl ... | bash ou bash <(curl ...)
    CONFS="$HOME/afs/.confs"
else
    CONFS="$(cd "$(dirname "$0")" && pwd)"
fi

RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
NC="\033[0m"

ok()   { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
info() { printf "${BLUE} ::${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}  !${NC} %s\n" "$1"; }
skip() { printf "  - %s\n" "$1"; }

# Supprime un symlink qui pointe vers $CONFS, restaure .bak si dispo
remove_link() {
    local dst="$1"
    if [ -L "$dst" ]; then
        local target="$(readlink "$dst")"
        # Résoudre ~ dans la cible pour la comparaison
        target_expanded="${target/#\~/$HOME}"
        if [[ "$target_expanded" == "$CONFS"* ]]; then
            rm "$dst"
            if [ -e "${dst}.bak" ]; then
                mv "${dst}.bak" "$dst"
                ok "  $dst restauré depuis .bak"
            else
                ok "  $dst supprimé"
            fi
        else
            skip "$dst (symlink vers un autre endroit, ignoré)"
        fi
    elif [ -e "${dst}.bak" ]; then
        warn "  $dst n'est pas un symlink mais un .bak existe — restauration"
        mv "${dst}.bak" "$dst"
    else
        skip "$dst (absent ou non-symlink, ignoré)"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# 1. ~/.config/[app]
# ══════════════════════════════════════════════════════════════════════════════
info "Suppression des symlinks ~/.config/ ..."

APPS="alacritty picom polybar rofi matugen clang-format dunst gtk-3.0 gtk-4.0 qt5ct qt6ct i3 flameshot"
for app in $APPS; do
    remove_link "$HOME/.config/$app"
done

remove_link "$HOME/.config/starship.toml"

# ══════════════════════════════════════════════════════════════════════════════
# 2. Dotfiles shell
# ══════════════════════════════════════════════════════════════════════════════
info "Suppression des dotfiles shell..."

for f in .bashrc .bash_aliases .bash_profile .bash_logout .gitconfig .vimrc .xprofile; do
    remove_link "$HOME/$f"
done

# ══════════════════════════════════════════════════════════════════════════════
# 3. GDB
# ══════════════════════════════════════════════════════════════════════════════
info "Suppression de ~/.gdbinit..."
remove_link "$HOME/.gdbinit"

# ══════════════════════════════════════════════════════════════════════════════
# 4. Emacs
# ══════════════════════════════════════════════════════════════════════════════
info "Suppression de ~/.emacs.d/init.el..."
remove_link "$HOME/.emacs.d/init.el"

# ══════════════════════════════════════════════════════════════════════════════
# 5. XCompose
# ══════════════════════════════════════════════════════════════════════════════
info "Suppression de ~/.XCompose..."
remove_link "$HOME/.XCompose"

# ══════════════════════════════════════════════════════════════════════════════
# 6. Firefox (optionnel — demande confirmation)
# ══════════════════════════════════════════════════════════════════════════════
info "Firefox ~/.mozilla..."
if [ -L "$HOME/.mozilla" ]; then
    target="$(readlink "$HOME/.mozilla")"
    target_expanded="${target/#\~/$HOME}"
    if [[ "$target_expanded" == "$CONFS"* ]] || [[ "$target_expanded" == *"afs/.confs"* ]]; then
        printf "${YELLOW}  ?${NC} ~/.mozilla est un symlink vers %s\n" "$target"
        printf "    Supprimer le symlink ? Le profil sur AFS sera conservé. [y/N] "
        if [ -t 0 ]; then
            read -r ans
        else
            ans="N"
            echo "N (stdin non-interactif, conservé par défaut)"
        fi
        if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
            rm "$HOME/.mozilla"
            ok "  ~/.mozilla supprimé (profil AFS conservé)"
        else
            skip "~/.mozilla conservé"
        fi
    else
        skip "~/.mozilla (pointe ailleurs, ignoré)"
    fi
else
    skip "~/.mozilla (non-symlink, ignoré)"
fi

# ══════════════════════════════════════════════════════════════════════════════
echo ""
info "Nettoyage terminé."
printf "${YELLOW}Relance i3 (mod+Shift+r) ou déconnecte-toi pour appliquer.${NC}\n"
