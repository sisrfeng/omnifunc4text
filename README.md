# vim-text-omnicomplete
`vim-text-omnicomplete` is a Vim autocomplete plugin for English words in plain
text files. It provides autocomplete suggestions of English words based on a
word frequency list. To improve the accuracy of suggestions, it also makes
suggestions based on the preceding word.

This plugin automatically sets the omni completion function (`omnifunc`) for
files with the text filetype. As such, when editing text files, you will
be able to use <kbd>Ctrl</kbd><kbd>x</kbd><kbd>Ctrl</kbd><kbd>o</kbd> to show
a list of autocomplete suggestions.

![vim-text-omnicomplete screenshot](screenshot.png)


## Installation
Specific installation steps depend on the plugin manager you use:

### Installation using Vim 8 package management
On Unix:
```bash
mkdir -p ~/.vim/pack/git-plugins/start/
cd ~/.vim/pack/git-plugins/start/
git clone https://github.com/cwfoo/vim-text-omnicomplete.git
```

On Windows using the 'Git for Windows' Bash terminal:
```bash
mkdir -p ~/vimfiles/pack/git-plugins/start/
cd ~/vimfiles/pack/git-plugins/start/
git clone https://github.com/cwfoo/vim-text-omnicomplete.git
```

### Installation using Vundle
You can install this plugin using [Vundle](https://github.com/VundleVim/Vundle.vim)
by adding the following line to your configuration and running `:PluginInstall`:
```vim
Plugin 'cwfoo/vim-text-omnicomplete'
```

### Installation using vim-plug
You can install this plugin using [vim-plug](https://github.com/junegunn/vim-plug)
by adding the following line to your configuration and running `:PlugInstall`:
```vim
Plug 'cwfoo/vim-text-omnicomplete'
```


## Documentation
See [doc/vim-text-omnicomplete.txt](doc/vim-text-omnicomplete.txt).


## Development Notes
Build dependencies:
* `make`
* `python` (any version)

`autoload/text_omnicomplete_data.vim` is built using the files in the `tools/`
directory. Run `make` to rebuild it. Although it is a generated file, it is
included in the git repository to make this plugin easier to install (no build
step necessary for end-users).


## License
This project is distributed under the BSD 3-Clause License (see LICENSE).
This project uses third-party components that are licensed under their own terms
(see LICENSE-3RD-PARTY).
