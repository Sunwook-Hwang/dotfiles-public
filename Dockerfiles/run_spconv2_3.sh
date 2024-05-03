#!/bin/bash

docker run --gpus all -it --rm --name sunwook_spconv2_3\
    --ipc=host \
  -v /data/OpenPCDet/:/root/OpenPCDet/data/ \
  -v /data/00_sunwookh_output/output_upcycling/:/root/OpenPCDet/output/ \
  -v /data/00_sunwookh_output/checkpoints_upcycling/:/root/OpenPCDet/checkpoints/ \
  -v $HOME/01_code/UpCycling/:/root/OpenPCDet/ \
  -e DISPLAY=unix$DISPLAY \
  -e TZ=Asia/Seoul \
  sunwookh/working_space:spconv2.x zsh
