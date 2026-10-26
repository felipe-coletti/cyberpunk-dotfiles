# Helper de idioma compartilhado pelos scripts dos dotfiles (uso: source)

# Escolhe o arquivo de tradução do locale do sistema dentro de um diretório
# Ordem: idioma exato (pt_BR) → mesmo idioma de outra região (pt_PT → pt_BR) → en_US
# Uso: resolve_lang <diretório> <extensão>  →  imprime o caminho do arquivo
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