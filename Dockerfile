# according to faceswap's setup.py, faceswap needs a ROCm version between 5.2 and 5.4.
FROM rocm/tensorflow:rocm5.4.1-tf2.10-dev

# not sure what this DEBIAN_FRONTEND does. I copied it from the Nvidia Dockerfile on the faceswap repo
ENV DEBIAN_FRONTEND noninteractive
ENV FACESWAP_BACKEND rocm
# I believe this tells ROCm that it can work with the 6700 XT, otherwise it refuses. https://www.reddit.com/r/ROCm/comments/uax358/build_for_unofficial_supported_gpu_6700xt_gfx1031/i9l2oqo/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0

RUN apt-get update -qq -y
RUN apt-get upgrade -y
RUN apt-get install -y libgl1 libglib2.0-0 python3-pip python3-tk git

# not sure if we need this
RUN ln -s $(which python3) /usr/local/bin/python

# we don't use the most recent commit on the faceswap repo, because its type hints cause errors in Python 3.9. So instead we check out the last commit before those type hints were changed.
RUN git clone https://github.com/deepfakes/faceswap.git
WORKDIR "./faceswap"
RUN git reset --hard e4ba12ad2a8e4d5dc6d56b9ec256ca474a58cadf
RUN git clean -df

# avoid a numpy version conflict. We could maybe also adjust the tensorflow in the requirements file, because I think (not sure) we have a compatible version already.
RUN sed -i "s|numpy>=1.25.0|numpy>=1.22.0|g" ./requirements/_requirements_base.txt
 
RUN python -m pip install --upgrade pip
RUN python -m pip --no-cache-dir install -r ./requirements/requirements_rocm.txt

CMD ["/bin/bash"]
