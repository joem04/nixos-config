# Light Crimson desktop

This repository defines a cohesive, keyboard-first Hyprland desktop using
NixOS and Home Manager. It takes visual inspiration from the LightCrimson
ML4W configuration while remaining Nix-native and intentionally independent
of its Arch install scripts, Quickshell implementation, machine-specific
settings, and external state files.

## Design contract

- **One palette:** a dark plum background, muted surfaces, and a restrained
  light-crimson accent are used by the compositor, bar, notifications,
  launcher, terminal, and wallpaper.
- **One type system:** JetBrains Mono Nerd Font is the UI/terminal default;
  installed Nerd Fonts provide dependable icon glyph fallbacks.
- **Keyboard first:** common window, workspace, launcher, screenshot, audio,
  brightness, and power actions are available without a mouse.
- **Predictable behavior:** Wayland-native utilities are preferred, while GTK
  and XWayland receive the same cursor/theme variables where supported.
- **Declarative only:** every managed desktop file is generated from this
  repository. No installer script or hand-edited file under `~/.config` is
  required.

## Implementation stages

1. **Foundation** — shared palette, generated wallpaper, baseline packages,
   and desktop documentation.
2. **Compositor** — Hyprland layout, input, animations, window rules, and
   ergonomic keybindings.
3. **Shell** — a themed Waybar, Wofi launcher, and Mako notifications.
4. **Applications** — coherent Alacritty, GTK/cursor, and helper-tool setup.
5. **Validation** — `nix flake check`, a NixOS build, activation, generated
   file review, and a short operational guide.

Each completed stage is validated and committed separately so the evolution is
easy to review and roll back.

## Daily controls

| Shortcut | Action |
|---|---|
| `Super + Return` | Terminal |
| `Super + Space` | Application launcher |
| `Super + B` | Firefox |
| `Super + Q` | Close focused window (or fully quit Vesktop) |
| `Super + F` / `Super + V` | Fullscreen / toggle floating |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + 1` … `9` | Switch workspace |
| `Super + Shift + 1` … `9` | Move focused window to workspace |
| `Super + Shift + S` | Region screenshot, opened in Swappy |
| `Super + C` | Clipboard history |
| Media / brightness keys | Volume, microphone mute, and backlight |

## Files

- `home/desktop/theme.nix` — the shared palette and font family.
- `home/desktop/lightcrimson.svg` — the generated wallpaper source.
- `home/desktop/hyprland.nix` — compositor and keybindings.
- `home/desktop/shell.nix` — Waybar, Wofi, and Mako.
- `home/desktop/terminal.nix` — Alacritty theme.

To change the accent palette, edit `theme.nix` and rebuild. Do not edit the
files under `~/.config` directly; Home Manager regenerates them.

## Login

The machine uses `greetd` with `tuigreet` instead of a graphical display
manager. The monochrome terminal greeter shows the time and starts Hyprland
when `joe` signs in. Use `Ctrl + Alt + F2` through `F6` for recovery TTYs.

## VS Code

VS Code uses the built-in Dark Modern theme with declarative monochrome color
and syntax overrides from `home/desktop/vscode.nix`. Restart VS Code after a
rebuild to load the generated settings.
