" Mode-aware cursor shape via DECSCUSR — also drives ghostty's sonic_boom
" shader (it triggers on cursor-width change). Mirrors nvim's guicursor.
let &t_SI = "\e[6 q"  " insert  -> beam
let &t_EI = "\e[2 q"  " normal  -> block
let &t_SR = "\e[4 q"  " replace -> underline

" herdr's edit_scrollback popup (prefix+e) loads this file instead of
" ~/.config/nvim/init.lua, so it misses LazyVim's clipboard=unnamedplus
" (lazyvim/config/options.lua:57). Mirror it here so yanks in that popup
" also sync to the system clipboard.
if empty($SSH_CONNECTION)
  set clipboard=unnamedplus
endif
