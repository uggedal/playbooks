#!/bin/sh

set $*

case "$1" in
  button/lid)
    _xauth=$(ps -C xinit -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')
    case "$3" in
      close)
        XAUTHORITY=$_xauth xset -display :0 dpms force off
        ;;
      open)
        XAUTHORITY=$_xauth xset -display :0 dpms force on
        ;;
    esac
    ;;
esac
