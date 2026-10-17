# zellij

`module.nix` defines the `settings` (config.kdl) and `layouts` options and
generates the files; `default.nix` sets the preferences and plugin bindings.
`base.kdl` is the default layout, with `@zjstatus@` replaced by the plugin's
store path. The plugins not in `pkgs.zellijPlugins` are the `zellij-room` and
`zellij-forgot` packages.

The preferences are ordinary assignments, not defaults, so conflicting
definitions fail evaluation; change them in `default.nix`.

Layouts are KDL files, copied as a whole, or `wlib.toKdl` data like
`settings`. In that format attrsets are written alphabetically, so use lists of
attrsets for repeated nodes or where order matters. A node with arguments and
children is a function returning `props` and `content`, a bare node a function
returning `{ }`:

```nix
settings.keybinds.shared = [
  {
    bind = _: {
      props = "Alt n";
      content.NewPane = _: { };
    };
  }
];
```

Binding lists merge, so this keeps the room and zellij-forgot bindings.
