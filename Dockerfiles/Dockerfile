# LATEX-docker image
# ==================================================================

FROM ubuntu:latest
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \
    rm -rf /var/lib/apt/lists/* \
    /etc/apt/sources.list.d/cuda.list \
    /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && \

    # ==================================================================
    # tools
    # ------------------------------------------------------------------
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    build-essential \
    sudo \
    wget \
    git \
    vim \
    htop \
    tmux \
    curl \
    npm \
    python3 \
    nodejs \
    pip

RUN npm cache clean -f && npm install -g n && sudo n stable && PATH="$PATH"

WORKDIR /root
# Set the locale
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8

# ===========================================
# fish
# -------------------------------------------
# RUN apt-get install -y fish
# CMD ["fish"]
# ===========================================
# zsh
# -------------------------------------------
RUN apt-get install -y zsh && \
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    apt-get install -y autojump && \
    # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
CMD [ "zsh" ]

# ===========================================
# nvim
# -------------------------------------------
RUN apt-get install -y software-properties-common && \
    apt-get update && \
    apt-get install -y ripgrep && \
    add-apt-repository ppa:neovim-ppa/unstable && \
    apt-get update && \
    apt-get install -y neovim && \
    curl -fLo .config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# config & cleanup
# ------------------------------------------------------------------
RUN ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

# RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
#     $PIP_INSTALL \
#         shapely fire pybind11 tensorboardX protobuf \
#         scikit-image numba pillow

# RUN wget https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz
# RUN tar xzvf boost_1_68_0.tar.gz
# RUN cp -r ./boost_1_68_0/boost /usr/include
# RUN rm -rf ./boost_1_68_0
# RUN rm -rf ./boost_1_68_0.tar.gz
# RUN git clone https://github.com/traveller59/second.pytorch.git --depth 10
# RUN git clone https://github.com/traveller59/SparseConvNet.git --depth 10
# RUN cd ./SparseConvNet && python setup.py install && cd .. && rm -rf SparseConvNet
# ENV NUMBAPRO_CUDA_DRIVER=/usr/lib/x86_64-linux-gnu/libcuda.so
# ENV NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
# ENV NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice
# ENV PYTHONPATH=/root/second.pytorch

# VOLUME ["/root/data"]
# VOLUME ["/root/model"]
# WORKDIR /root/second.pytorch/second

# ENTRYPOINT ["fish"]
