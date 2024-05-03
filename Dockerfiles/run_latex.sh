#!/bin/bash

docker run -it \
    -v $HOME/dotfiles/:/root/dotfiles/ \
    -v $HOME/99_JCN/:/root/JCN/ \
    -e DISPLAY=unix$DISPLAY \
    -e TZ=Asia/Seoul \
    -p 6789:8888 sunwookh/working_space:latex
