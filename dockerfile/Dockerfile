
FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive

# various helper tools
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get update
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get install -y wget vim
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get install -y virtualenv
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get install -y python3.10


#RUN mkdir -p /mnt/host
#WORKDIR /mnt/host

#COPY venv /mnt/host/venv

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get install -y python3.10-distutils python3.10-dev

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get install -y git



# copy code
RUN mkdir -p /mnt/host
#COPY ../*.py /mnt/host
#COPY ../data /mnt/host/data
#COPY ../.git /mnt/host/.git
#RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
#    --mount=target=/var/cache/apt,type=cache,sharing=locked \
#  apt-get update

# this should not invalidate cache since the command is the same
RUN --mount=type=secret,id=git-key \
    cd /mnt/host && \
    git clone "https://github.com/pongnguy/cs234_final" cs234_final
#RUN mv /mnt/host/venv /mnt/host/cs234/venv

WORKDIR /mnt/host/cs234_final
RUN git checkout main

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  virtualenv venv

RUN --mount=type=cache,target=/root/.cache/pip \
  venv/bin/pip install accelerate

RUN --mount=type=cache,target=/root/.cache/pip \
  venv/bin/pip install -r requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
  venv/bin/pip install jupyter

#RUN --mount=type=cache,target=/root/.cache/pip \
#  venv/bin/pip install -e .


#COPY --link ./ /mnt/host/

## copy venv
#COPY --link --from=environment /mnt/host/ /mnt/host/
RUN touch /root/.no_auto_tmux

# TODO download and install pycharm client
# cython debugger compile
#RUN /usr/bin/python3 /<PYCHARM_INSTALLATION_PATH>/plugins/python/helpers/pydev/setup_cython.py build_ext --inplace

## copy conda
#COPY --link --from=environment /root/miniconda3 /root/miniconda3
#RUN echo "export PATH=$PATH:/root/miniconda3/bin" >> ~/.bashrc # && source ~/.bashrc
## copy mujoco
#COPY --link --from=environment /root/.mujoco /root/.mujoco

# copy ssh key for downloading data
#RUN --mount=type=secret,id=ssh_key \
#    mkdir /root/.ssh && \
#    cp /run/secrets/ssh_key /root/.ssh/id_rsa
#RUN chmod 600 /root/.ssh/id_rsa

#WORKDIR /mnt/host
#CMD ["/root/miniconda3/bin/conda", "run", "--no-capture-output", "-n", "cs234_hw3", "conda", "activate", "cs234_hw3"]
#ENTRYPOINT ["/root/miniconda3/bin/conda", "run", "--no-capture-output", "-n", "cs234_hw3", "/bin/bash"]
#ENTRYPOINT ["/root/miniconda3/bin/conda", "activate", "cs234_hw3"]
#RUN echo "source /root/miniconda3/bin/activate cs234_hw3" >> ~/.bashrc
#ENTRYPOINT . ~/.bashrc && conda activate cs234_hw3
