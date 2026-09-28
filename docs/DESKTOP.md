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
