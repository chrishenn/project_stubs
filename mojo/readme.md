# mojo

After much faffing, I got a debugger working in vscode. Very specifically:

- with mojo 25.5.0
- vscode's mojo-nightly extension (not the mainline mojo extension)
- using the command: `mojo debug -I . --vscode hello2.mojo`

Right now, jetbrains' mojo extension doesn't support debugging at all, but the language server is working for
syntax.
