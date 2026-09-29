{ pkgs, lib, ... }:

let
  theme = import ./theme.nix;
  extensionManifest = builtins.toJSON {
    name = "lightcrimson-monochrome-theme";
    displayName = "Light Crimson Monochrome";
    description = "A monochrome theme matching the NixOS desktop.";
    version = "1.0.0";
    publisher = "joem04";
    engines.vscode = "^1.85.0";
    categories = [ "Themes" ];
    contributes.themes = [ {
      label = "Light Crimson Monochrome";
      uiTheme = "vs-dark";
      path = "./themes/lightcrimson-monochrome-color-theme.json";
    } ];
  };
  colorTheme = builtins.toJSON {
    name = "Light Crimson Monochrome";
    type = "dark";
    colors = {
      foreground = "#${theme.text}";
      descriptionForeground = "#${theme.muted}";
      focusBorder = "#${theme.accent}";
      "textLink.foreground" = "#${theme.text}";
      "textLink.activeForeground" = "#${theme.accentStrong}";

      "editor.background" = "#${theme.background}";
      "editor.foreground" = "#${theme.text}";
      "editorCursor.foreground" = "#${theme.accentStrong}";
      "editor.lineHighlightBackground" = "#${theme.backgroundAlt}";
      "editor.selectionBackground" = "#${theme.surfaceBright}";
      "editor.inactiveSelectionBackground" = "#${theme.surface}";
      "editor.findMatchBackground" = "#${theme.surfaceBright}";
      "editor.findMatchHighlightBackground" = "#${theme.surface}";
      "editor.wordHighlightBackground" = "#${theme.surface}";
      "editorIndentGuide.background1" = "#${theme.surface}";
      "editorIndentGuide.activeBackground1" = "#${theme.accentDim}";
      "editorWhitespace.foreground" = "#${theme.surfaceBright}";
      "editorGroup.border" = "#${theme.surface}";
      "editorGroupHeader.tabsBackground" = "#${theme.background}";
      "editorWidget.background" = "#${theme.backgroundAlt}";
      "editorWidget.border" = "#${theme.surfaceBright}";
      "editorSuggestWidget.background" = "#${theme.backgroundAlt}";
      "editorSuggestWidget.selectedBackground" = "#${theme.surfaceBright}";
      "editorHoverWidget.background" = "#${theme.backgroundAlt}";
      "editorHoverWidget.border" = "#${theme.surfaceBright}";

      "sideBar.background" = "#${theme.backgroundAlt}";
      "sideBar.foreground" = "#${theme.muted}";
      "sideBar.border" = "#${theme.surface}";
      "sideBarTitle.foreground" = "#${theme.text}";
      "activityBar.background" = "#${theme.background}";
      "activityBar.foreground" = "#${theme.text}";
      "activityBar.inactiveForeground" = "#${theme.accentDim}";
      "activityBar.border" = "#${theme.surface}";
      "list.activeSelectionBackground" = "#${theme.surfaceBright}";
      "list.activeSelectionForeground" = "#${theme.text}";
      "list.hoverBackground" = "#${theme.surface}";
      "list.focusOutline" = "#${theme.accentDim}";

      "tab.activeBackground" = "#${theme.surface}";
      "tab.activeForeground" = "#${theme.text}";
      "tab.inactiveBackground" = "#${theme.background}";
      "tab.inactiveForeground" = "#${theme.muted}";
      "tab.border" = "#${theme.surface}";
      "tab.activeBorderTop" = "#${theme.accentStrong}";
      "statusBar.background" = "#${theme.backgroundAlt}";
      "statusBar.foreground" = "#${theme.muted}";
      "statusBar.border" = "#${theme.surface}";
      "titleBar.activeBackground" = "#${theme.background}";
      "titleBar.activeForeground" = "#${theme.text}";
      "titleBar.inactiveBackground" = "#${theme.background}";
      "titleBar.border" = "#${theme.surface}";
      "panel.background" = "#${theme.background}";
      "panel.border" = "#${theme.surface}";
      "panelTitle.activeForeground" = "#${theme.text}";
      "panelTitle.inactiveForeground" = "#${theme.muted}";
      "terminal.background" = "#${theme.background}";
      "terminal.foreground" = "#${theme.text}";
      "terminalCursor.foreground" = "#${theme.accentStrong}";
      "terminal.ansiBlack" = "#${theme.background}";
      "terminal.ansiBrightBlack" = "#${theme.accentDim}";
      "terminal.ansiWhite" = "#${theme.text}";
      "terminal.ansiBrightWhite" = "#${theme.accentStrong}";
      "gitDecoration.addedResourceForeground" = "#${theme.text}";
      "gitDecoration.modifiedResourceForeground" = "#${theme.muted}";
      "gitDecoration.deletedResourceForeground" = "#${theme.accentDim}";
      "notificationCenterHeader.background" = "#${theme.backgroundAlt}";
      "notifications.background" = "#${theme.backgroundAlt}";
      "notifications.border" = "#${theme.surfaceBright}";
    };
    tokenColors = [
      { scope = [ "comment" "punctuation.definition.comment" ]; settings = { foreground = "#${theme.accentDim}"; fontStyle = "italic"; }; }
      { scope = [ "keyword" "storage" "storage.type" "keyword.control" "keyword.operator" ]; settings = { foreground = "#${theme.text}"; fontStyle = "bold"; }; }
      { scope = [ "string" "constant.numeric" "constant.language" "constant.character" ]; settings = { foreground = "#${theme.muted}"; }; }
      { scope = [ "entity.name.function" "support.function" "variable.function" ]; settings = { foreground = "#${theme.accentStrong}"; }; }
      { scope = [ "entity.name.type" "support.type" "entity.name.class" "entity.name.namespace" ]; settings = { foreground = "#${theme.accent}"; }; }
      { scope = [ "variable" "variable.parameter" "identifier" ]; settings = { foreground = "#${theme.text}"; }; }
      { scope = [ "punctuation" "meta.brace" ]; settings = { foreground = "#${theme.muted}"; }; }
      { scope = [ "invalid" "invalid.illegal" ]; settings = { foreground = "#${theme.text}"; background = "#${theme.surfaceBright}"; }; }
    ];
    semanticTokenColors = {
      namespace = "#${theme.accent}";
      class = "#${theme.accent}";
      type = "#${theme.accent}";
      function = "#${theme.accentStrong}";
      method = "#${theme.accentStrong}";
      variable = "#${theme.text}";
      parameter = "#${theme.muted}";
      property = "#${theme.text}";
      keyword = "#${theme.text}";
      string = "#${theme.muted}";
      number = "#${theme.muted}";
      comment = { foreground = "#${theme.accentDim}"; italic = true; };
    };
  };
  extensionManifestFile = pkgs.writeText "lightcrimson-monochrome-package.json" extensionManifest;
  colorThemeFile = pkgs.writeText "lightcrimson-monochrome-color-theme.json" colorTheme;
  themeVsix = pkgs.runCommand "lightcrimson-monochrome-theme-1.0.0.vsix" {
    nativeBuildInputs = [ pkgs.zip ];
  } ''
    mkdir -p extension/themes
    cp ${extensionManifestFile} extension/package.json
    cp ${colorThemeFile} extension/themes/lightcrimson-monochrome-color-theme.json
    chmod -R u+w extension
    zip -qr "$out" extension
  '';
  settings = {
    "workbench.colorTheme" = "Light Crimson Monochrome";
    "workbench.iconTheme" = "vs-seti";
    "window.titleBarStyle" = "native";
    "window.commandCenter" = false;
    "window.customTitleBarVisibility" = "never";
    "workbench.activityBar.location" = "default";
    "workbench.editor.labelFormat" = "short";
    "workbench.editor.enablePreview" = false;
    "workbench.startupEditor" = "none";
    "workbench.editor.showTabs" = "multiple";
    "workbench.statusBar.visible" = true;
    "workbench.tips.enabled" = false;
    "workbench.sideBar.location" = "right";
    "workbench.tree.enableStickyScroll" = false;
    "workbench.tree.renderIndentGuides" = "none";
    "explorer.compactFolders" = false;
    "explorer.confirmDragAndDrop" = false;
    "explorer.confirmDelete" = false;
    "explorer.decorations.badges" = false;
    "git.decorations.enabled" = false;
    "workbench.tree.indent" = 8;

    "editor.fontFamily" = "${theme.font}, monospace";
    "editor.fontLigatures" = false;
    "editor.fontSize" = 15;
    "editor.lineHeight" = 0;
    "editor.cursorStyle" = "line";
    "editor.cursorBlinking" = "solid";
    "editor.minimap.enabled" = false;
    "editor.renderWhitespace" = "none";
    "editor.guides.indentation" = false;
    "editor.bracketPairColorization.enabled" = false;
    "editor.stickyScroll.enabled" = false;
    "breadcrumbs.enabled" = false;
    "editor.colorDecorators" = false;
    "editor.codeLens" = false;
    "editor.links" = false;
    "editor.matchBrackets" = "never";
    "editor.lightbulb.enabled" = "off";
    "editor.hover.enabled" = false;
    "editor.showFoldingControls" = "never";
    "editor.renderLineHighlight" = "none";
    "editor.occurrencesHighlight" = "off";
    "editor.selectionHighlight" = false;
    "editor.scrollbar.horizontal" = "hidden";
    "editor.scrollbar.vertical" = "hidden";
    "editor.overviewRulerBorder" = false;
    "editor.hideCursorInOverviewRuler" = true;
    "editor.tabSize" = 2;
    "editor.detectIndentation" = false;
    "files.trimTrailingWhitespace" = true;
    "files.insertFinalNewline" = true;
    "files.autoSave" = "afterDelay";
    "scm.diffDecorations" = "none";
    "update.mode" = "none";
    "extensions.ignoreRecommendations" = true;

    "terminal.integrated.fontFamily" = "${theme.font}, monospace";
    "terminal.integrated.fontSize" = 14;
    "terminal.integrated.cursorStyle" = "line";

    "workbench.colorCustomizations" = {
      "foreground" = "#${theme.text}";
      "focusBorder" = "#${theme.accent}";
      "selection.background" = "#${theme.surfaceBright}";
      "textLink.foreground" = "#${theme.text}";

      "editor.background" = "#${theme.background}";
      "editor.foreground" = "#${theme.text}";
      "editorCursor.foreground" = "#${theme.accentStrong}";
      "editor.lineHighlightBackground" = "#${theme.backgroundAlt}";
      "editor.selectionBackground" = "#${theme.surfaceBright}";
      "editor.inactiveSelectionBackground" = "#${theme.surface}";
      "editorIndentGuide.background1" = "#${theme.surface}";
      "editorIndentGuide.activeBackground1" = "#${theme.accentDim}";
      "editorWhitespace.foreground" = "#${theme.surfaceBright}";
      "editorGroup.border" = "#${theme.surface}";
      "editorGroupHeader.tabsBackground" = "#${theme.background}";

      "sideBar.background" = "#${theme.backgroundAlt}";
      "sideBar.foreground" = "#${theme.muted}";
      "sideBar.border" = "#${theme.surface}";
      "sideBarTitle.foreground" = "#${theme.text}";
      "list.activeSelectionBackground" = "#${theme.surfaceBright}";
      "list.hoverBackground" = "#${theme.surface}";
      "list.focusOutline" = "#${theme.accentDim}";

      "tab.activeBackground" = "#${theme.surface}";
      "tab.activeForeground" = "#${theme.text}";
      "tab.inactiveBackground" = "#${theme.background}";
      "tab.inactiveForeground" = "#${theme.muted}";
      "tab.border" = "#${theme.surface}";
      "tab.activeBorderTop" = "#${theme.accentStrong}";

      "statusBar.background" = "#${theme.backgroundAlt}";
      "statusBar.foreground" = "#${theme.muted}";
      "statusBar.border" = "#${theme.surface}";
      "titleBar.activeBackground" = "#${theme.background}";
      "titleBar.activeForeground" = "#${theme.text}";
      "titleBar.inactiveBackground" = "#${theme.background}";
      "titleBar.border" = "#${theme.surface}";

      "terminal.background" = "#${theme.background}";
      "terminal.foreground" = "#${theme.text}";
      "terminalCursor.foreground" = "#${theme.accentStrong}";
      "terminal.ansiBlack" = "#${theme.background}";
      "terminal.ansiBrightBlack" = "#${theme.accentDim}";
      "terminal.ansiWhite" = "#${theme.text}";
      "terminal.ansiBrightWhite" = "#${theme.accentStrong}";
    };

    "editor.tokenColorCustomizations" = {
      "textMateRules" = [
        {
          scope = [ "comment" "punctuation.definition.comment" ];
          settings = { foreground = "#${theme.accentDim}"; fontStyle = "italic"; };
        }
        {
          scope = [ "keyword" "storage" "storage.type" "keyword.control" ];
          settings = { foreground = "#${theme.text}"; fontStyle = "bold"; };
        }
        {
          scope = [ "string" "constant.numeric" "constant.language" ];
          settings = { foreground = "#${theme.muted}"; };
        }
        {
          scope = [ "entity.name.function" "support.function" "variable.function" ];
          settings = { foreground = "#${theme.accentStrong}"; };
        }
        {
          scope = [ "entity.name.type" "support.type" "entity.name.class" ];
          settings = { foreground = "#${theme.accent}"; };
        }
        {
          scope = [ "variable" "variable.parameter" "identifier" ];
          settings = { foreground = "#${theme.text}"; };
        }
      ];
    };
  };
  settingsFile = pkgs.writeText "vscode-settings.json" (builtins.toJSON settings);
  baselineVersion = "3";
in
{

  home.activation.vscodeThemeExtension = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    stateDir="$HOME/.local/state/nixos"
    state="$stateDir/vscode-lightcrimson-theme-v1"
    if [ ! -e "$state" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf "$HOME/.vscode/extensions/joem04.lightcrimson-monochrome-theme-1.0.0"
      $DRY_RUN_CMD ${pkgs.vscode}/bin/code --install-extension ${themeVsix} --force
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$stateDir"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/touch "$state"
    fi
  '';

  # A versioned baseline lets intentional rice updates apply once without
  # rewriting VS Code's settings while the editor is running on later rebuilds.
  home.activation.vscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.config/Code/User/settings.json"
    stateDir="$HOME/.local/state/nixos"
    state="$stateDir/vscode-rice-settings-v${baselineVersion}"

    if [ -L "$target" ] || [ ! -e "$target" ] || [ ! -e "$state" ]; then
      if [ -f "$target" ] && [ ! -L "$target" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp -a "$target" "$target.nixos-rice-backup"
      fi
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "$target"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm644 ${settingsFile} "$target"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$stateDir"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/touch "$state"
    fi
  '';
}
