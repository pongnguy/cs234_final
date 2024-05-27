
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
RUN cd /mnt/host && \
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

#RUN --mount=type=cache,target=/root/.cache/pip \
#  venv/bin/pip install -e .

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get install -y apt-transport-https ca-certificates gnupg curl
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
  apt-get update && apt-get install -y google-cloud-cli
RUN --mount=type=cache,target=/root/.cache/pip \
  venv/bin/pip install dvc[gs]


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


RUN apt update && apt install  openssh-server sudo -y

#RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 alfred

RUN echo 'root:Cc17931793' | chpasswd #echo 'alfred:Cc17931793' | chpasswd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    #sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    #echo 'export NOTVISIBLE="in users profile"' >> ~/.bashrc && \
    #echo "export VISIBLE=now" >> /etc/profile

RUN service ssh start

## copy pycharm remote dev
#RUN mkdir -p /mnt/.cache/JetBrains/RemoteDev/dist
#COPY --link --from=remotedev dist/ /mnt/.cache/JetBrains/RemoteDev/dist/
RUN touch /root/.no_auto_tmux
#RUN if ! [ -d /home/alfred ]; then mkdir /home/alfred; fi; chown -R alfred /home/alfred

EXPOSE 22

RUN apt-get install tini
ENTRYPOINT ["/tini", "--"]
CMD ["/usr/sbin/sshd", "-D"]
#ENTRYPOINT ["/usr/sbin/sshd","-D"]
#CMD ["/mnt/host/cs234_final/venv/bin/python", "jupyter", "lab", "--allow-root", "--autoreload", "--no-browser"]