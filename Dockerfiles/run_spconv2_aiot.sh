#!/bin/bash

docker run --gpus all -it --rm --name sunwook_spconv2\
    --ipc=host \
  -v /dataset/data_sunwook/OpenPCDet:/root/OpenPCDet/data/ \
  -v $HOME/01_code/UpCycling/:/root/OpenPCDet/ \
  -v /00_sunwookh_model/:/root/model/ \
  -e DISPLAY=unix$DISPLAY \
  -e TZ=Asia/Seoul \
  sunwookh/working_space:spconv2.x zsh
