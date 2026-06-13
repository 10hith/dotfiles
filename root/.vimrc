" Mode-aware cursor shape via DECSCUSR — also drives ghostty's sonic_boom
" shader (it triggers on cursor-width change). Mirrors nvim's guicursor.
let &t_SI = "\e[6 q"  " insert  -> beam
let &t_EI = "\e[2 q"  " normal  -> block
let &t_SR = "\e[4 q"  " replace -> underline
