{ ... }:

let
  theme = import ./theme.nix;
in
{
  # VS Code's built-in Dark Modern theme remains the syntax base; these
  # overrides make the chrome, editor, terminal, and code palette match the
  # monochrome desktop without relying on a mutable Marketplace extension.
  xdg.configFile."Code/User/settings.json".text = builtins.toJSON {
    "workbench.colorTheme" = "Default Dark Modern";
    "workbench.iconTheme" = "vs-seti";
    "window.titleBarStyle" = "custom";
    "window.commandCenter" = false;
    "workbench.activityBar.location" = "hidden";
    "workbench.editor.labelFormat" = "short";
    "workbench.editor.enablePreview" = false;
    "workbench.startupEditor" = "none";
    "workbench.tree.indent" = 12;

    "editor.fontFamily" = "${theme.font}, monospace";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 15;
    "editor.lineHeight" = 24;
    "editor.cursorStyle" = "line";
    "editor.cursorBlinking" = "smooth";
    "editor.minimap.enabled" = false;
    "editor.renderWhitespace" = "selection";
    "editor.guides.indentation" = false;
    "editor.bracketPairColorization.enabled" = false;
    "editor.stickyScroll.enabled" = false;
    "breadcrumbs.enabled" = false;

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
}
