# fzf-gitswitch.vim

## Install

to use vim-plug::

```vim
Plug 'junegunn/fzf'
Plug 'ichihara-3/fzf-gitswitch.vim'
```

## commands

### :Branches

This command shows both remote and local branches in fzf window, and when selected, checkouts it.
If you need your branches up to date with a remote, please do git fetch before run the command.
Note that when local changes are not committed, the command may be failed.

## Key mappings

The plugin key mapping `<Plug>(fzf_gs)` is defined.

example::

```vim
nmap <leader>gs <Plug>(fzf_gs)
```

