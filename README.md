# cyberpunk-dotfiles

Uma versão dos meus [dotfiles](https://github.com/felipe-coletti/dotfiles) para **Arch Linux + Hyprland** com visual cyberpunk: preto puro, branco neon e cantos retos, no mesmo design do [to-do-list](https://github.com/felipe-coletti/to-do-list).

## Instalação

```bash
git clone https://github.com/felipe-coletti/cyberpunk-dotfiles ~/.cyberpunk-dotfiles
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

## Licença

[MIT](LICENSE)
