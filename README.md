# fzf-gitswitch.vim

## Install

using vim-plug::

```vim
Plug 'junegunn/fzf'
Plug 'ichihara-3/fzf-gitswitch.vim'
```

## commands

### :Branches

This command shows both remote and local branches in fzf window, and when selected, checkout it.
Note that when local changes not commited exists, command may be failed.

## Key mappings

Plugin keymappings `<Plug>(fzf_gs)` is defined.

example::

```vim
nmap <leader>gs <Plug>(fzf_gs)
```

