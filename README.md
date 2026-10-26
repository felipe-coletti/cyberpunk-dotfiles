# Cyberpunk Dotfiles

![Desktop com neon ciano](screenshots/screenshot-cian.png)

## Instalação

```bash
git clone <repository-url> ~/.cyberpunk-dotfiles
cd ~/.cyberpunk-dotfiles
./install.sh
```

## Cor do neon

O neon é branco por padrão. Para trocar, aperte `SUPER + N` ou clique no ícone de paleta na waybar e escolha a cor na roda de cores. O botão **Padrão** volta ao branco.

Também dá para aplicar uma cor direto pelo terminal:

```bash
~/.config/neon/apply.sh 00ffcc
```

Apps GTK que já estavam abertos (como o Thunar) só mudam de cor ao reiniciar.

## Idiomas

Os textos dos menus, da waybar e da roda de cores seguem o idioma do sistema. Os idiomas disponíveis são os 10 mais falados do mundo:

| Idioma | Código |
| --- | --- |
| Inglês | `en_US` |
| Mandarim (simplificado) | `zh_CN` |
| Hindi | `hi_IN` |
| Espanhol | `es_ES` |
| Árabe | `ar_SA` |
| Francês | `fr_FR` |
| Bengali | `bn_BD` |
| Português | `pt_BR` |
| Russo | `ru_RU` |
| Indonésio | `id_ID` |

Outras variantes de um idioma usam a tradução dele (por exemplo, `es_MX` usa `es_ES`, e `pt_PT` usa `pt_BR`). Idiomas sem tradução usam o inglês.

## Licença

[MIT](LICENSE)
