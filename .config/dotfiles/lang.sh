# Language helper shared by the dotfiles scripts (usage: source)

# Picks the translation file for the system locale inside a directory
# Order: exact language (pt_BR) → same language, another region (pt_PT → pt_BR) → en_US
# Usage: resolve_lang <directory> <extension>  →  prints the file path
resolve_lang() {
    local dir="$1" ext="$2"
    local lang="${LC_ALL:-${LC_MESSAGES:-$LANG}}"
    lang="${lang%%.*}"

    if [[ -n "$lang" && -f "$dir/$lang.$ext" ]]; then
        echo "$dir/$lang.$ext"
        return
    fi

    local match
    match=$(compgen -G "$dir/${lang%%_*}_*.$ext" | head -n 1)
    echo "${match:-$dir/en_US.$ext}"
}