toolboxes (https://github.com/containers/toolbox) are cool.

Here are a few initialization scripts for toolboxes.

* `build` prefix automatically builds and installs a/the tool (not installing dependencies into the actual system)
* `dev` prefix composes a build/dev environment
* `dep` prefix for common dependency sets.
* `host` prefix for commands that are hosted inside a container because of dynamically linked dependencies



Here is a list of commands to install stuff:

```
tb-create-with-command scrcpy scrcpy ~/dotfiles/toolboxes/host_scrcpy.sh
tb-create-with-command atom "atom -f" ~/dotfiles/toolboxes/host_atom.sh
tb-create-with-command mkchromecast mkchromecast ~/dotfiles/toolboxes/host_mkchromecast.sh
tb-create-with-command Zettlr Zettlr ~/dotfiles/toolboxes/host_zettlr.sh

tb-run-tmp ~/dotfiles/toolboxes/build_silicon.sh
```
