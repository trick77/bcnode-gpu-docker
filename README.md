# What's this about?

Mining on Block Collider's blockchain with LG's CUDA RPC miner in a Docker container.

Important reminder: If something doesn't work, don't complain about it. Analyze it, fix it, improve it, submit a pull request.

## Prerequisites
1. Linux-capable x86_64 PC with at least 10 GB RAM
    1. It doesn't need a fast CPU but something faster than an Atom/Celeron may be required for low latency rovering.
    1. SSD always helps.
1. At least one CUDA compatible Nvidia GPU.
1. Preferably a low latency Internet connection.
1. Some basic Linux skills.

## Installation
In a nutshell:
1. Install Debian 10 Buster as the host OS.
1. Install the appropriate tools like ```apt-get install -y git wget curl ca-certificates```
1. Install Docker from https://docs.docker.com/install/linux/docker-ce/debian/
1. Install Nvidia's CUDA Drivers from https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=1804 
    1. Use the **runfile** installer type and installation instructions.
1. Install https://github.com/NVIDIA/nvidia-docker
1. This might be a good time for a system reboot.
1. ```git clone https://github.com/trick77/bcnode-gpu-docker bcnode-gpu-docker && cd $_```
1. Build the Docker images locally using ```./build-images.sh``` (grab an 0xc0ffee since this will take a while)
1. If the image build was a success, start the containers with the provided ```./start.sh``` in this directory

Unfortunately, we can't use docker-compose for the whole thing yet since it doesn't support the required gpu flag.

Gotchas:
1. Watch for errors if sudo is not installed. While sudo is not required it's contained in some of the manual installation instructions.
1. The provided start script will output if Docker is able to find a compatible GPU on the host. If the output doesn't show any compatible GPU, you have to fix this first.
1. You want to re-run ```./build-images.sh``` whenever a new blockcollider/bcnode image is released or you will mine on an outdated version rather sooner than later.
1. You didn't read this README.


## Tips & tricks
* To see what bcnode is currently doing use ```docker logs -f bcnode --tail 100```, abort the output with CTRL-C (this will not terminate the process)
* Use ```docker volume rm db``` to get rid of the blockchain database and start syncing from scratch. You obviously want to do this when the bcnode container is not currently running.
    * The named volume will only be created if the provided start script was used.

## Thanks

Kudos go out to all the nerds in the BC GPU Miner Tester community for their tech and moral support.

## A message to the Block Collider team

Please support this development with:

1. Make the GRPC miner URL fully customizable via env variable
1. Create a way to plug in a 3rd party miner. Not disabling the Rust miner in officer.js would be a start.
1. Handle ```MinerResponseResult.CANCELED and MinerResponseResult.ERROR``` in officer.js

And please, stop with the closed source crap. Put all the source code and the build pipeline in a public Github repository so we don't have to dig out the transpiled results from your Docker images. It helps to support your developments and you are required to do so by law since you're using components which are released under GNU GPL:
> "The source code for a work means the preferred form of the work for making modifications to it. For an executable work, complete source code means all the source code for all modules it contains, plus any associated interface definition files, plus the scripts used to control compilation and installation of the executable."
