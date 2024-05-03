#!/bin/bash

docker run --gpus all -it --rm --name sunwook_conda_upcycling\
  -v /ssd_data/data_dla/OpenPCDet_data/:/root/OpenPCDet/data/ \
  -v $HOME/01_code/UpCycling/:/root/OpenPCDet/ \
  -v /00_sunwookh_model/:/root/model/ \
  -e DISPLAY=unix$DISPLAY \
  -e TZ=Asia/Seoul \
  -p 6780:8888 \
  sunwookh/working_space:miniconda

