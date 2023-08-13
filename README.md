This sets up faceswap in a docker image, with the ability to use the system's AMD GPU to train. It works on my system (Ubuntu with ROCm 5.6 installed, and AMD RX 6700 XT) as of 2023-08-12, but perhaps not yours.

_Disclaimer: My understanding of Docker is poor, and I don't promise any support._

# Steps
1) have ROCm installed on the host machine
2) clone this repo
3) cd into the repo
4) ```sudo docker build . -t 'rocm_fswap_tensorflow'```
5) ```xhost +local: && sudo docker run --rm -it --network=host --device=/dev/kfd --device=/dev/dri --group-add=video --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/dockerx:/dockerx -e DISPLAY=${DISPLAY} rocm_fswap_tensorflow```
6) inside the docker image, run ```python faceswap.py gui```

## Explanation of commands
- The docker build command uses the dockerfile in the current directory and gives it a memorable tag
- The tag in step 4 will need to match step 5
- The xhost stuff is synthesised from the ["Docker Nvidia" section](https://github.com/deepfakes/faceswap/blob/master/INSTALL.md ) from the faceswap github and [this DockerHub page](https://hub.docker.com/r/rocm/tensorflow/#!).
    - I suspect the runtime keyword is only required for NVIDIA GPUs
    - I don't know if you need sudo
    - The "-v" section means you will share a folder (volume) with the Docker container. So if you put stuff into ~/dockerx on your local machine, then you'll be able to access it from your docker image using path /dockerx
