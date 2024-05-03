#!/bin/bash

docker run --gpus all -it --rm \
    -v /ssd_project_data/data_dla/kitti_data_detection/:/root/data/ \
    -v $HOME/01_code/fed_pp/:/root/second.pytorch/ \
    -v /00_yskim_model/:/root/model/ \
    -v $HOME/dotfiles/:/root/dotfiles/ \
    -e DISPLAY=unix$DISPLAY \
    -e TZ=Asia/Seoul \
    -p 6780:8888 \
    sunwookh/working_space:latest zsh
