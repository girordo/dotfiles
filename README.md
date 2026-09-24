<section align="center">

<img src="https://github.com/girordo/dotfiles/blob/main/assets/dotfiles.png?raw=true" alt="dotfiles logo"/>

<h1>𝕬𝖇𝖔𝖚𝖙</h1>
Simple dotfiles

<h2>𝖎𝖓𝖘𝖙𝖆𝖑𝖑𝖊𝖉</h2>
i3wm
sway
waybar
picom
nvim
yazi
greenclip
redshift
lightdm & slick-greeter
[bat](https://github.com/sharkdp/bat)
[lsd](https://github.com/Peltoche/lsd)
[fd](https://github.com/sharkdp/fd)
[sd](https://github.com/chmln/sd)
[xh](https://github.com/ducaale/xh)
[kitty](https://github.com/kovidgoyal/kitty)
[rofi](https://github.com/davatorium/rofi)
[Bibata Modern Ice Cursor](https://github.com/ful1e5/Bibata_Cursor)

</section>

## Setup no Laptop

Para replicar as configurações do Desktop em uma nova máquina (ex.: Laptop):

### 1. Cursor (Bibata-Modern-Ice)
Execute o script para baixar o tema de cursor e aplicar as configurações de usuário (`~/.Xresources`, `~/.profile`, GTK 3/4 e `xsettingsd`):
```bash
./scripts/install-cursor.sh
```
> Opcional: Para disponibilizar o cursor também na tela de login, execute `./scripts/install-cursor.sh --system` (ou `sudo ./scripts/install-cursor.sh`).

### 2. Tela de Login (LightDM + Slick Greeter)
Instala e configura o LightDM, Slick Greeter e o papel de parede `lofi-background.jpg`:
```bash
sudo ./scripts/setup-login.sh
```
Para testar a tela de login sem reiniciar:
```bash
slick-greeter --test-mode
```

### 3. Sway & Waybar (Wayland)
Para instalar os pacotes do ecossistema Wayland (Sway, Waybar, cliphist, grim, slurp, gammastep, etc.) e aplicar os links simbólicos de configuração (`~/.config/sway` e `~/.config/waybar`):
```bash
./scripts/setup-sway.sh
```

Para habilitar suporte nativo a **animações, cantos arredondados, sombras e blur**, instale o **SwayFX**:
```bash
./scripts/setup-sway.sh --fx
```


## License

This project is [MIT licensed](LICENSE).

---

<div align="center">
  <sub>Made with 💜 by <a href="https://github.com/girordo">Tarcísio Giroldo</a></sub>
</div>
