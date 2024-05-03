#!/bin/bash

docker run --gpus all -it --rm --name sunwook_tensorboard\
  -v $HOME/01_code/UpCycling/:/root/OpenPCDet/ \
  -e DISPLAY=unix$DISPLAY \
  -e TZ=Asia/Seoul \
  -p 6006:6006 \
  -p 6007:6007 \
  -p 6008:6008 \
  -p 6009:6009 \
  sunwookh/working_space:tensorboard
