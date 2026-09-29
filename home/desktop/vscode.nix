{ pkgs, lib, ... }:

let
  theme = import ./theme.nix;
  settings = {
    "workbench.colorTheme" = "Default Dark Modern";
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
  baselineVersion = "2";
in
{
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
