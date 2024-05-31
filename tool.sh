#!/bin/bash

MEMORY="-m 2048M"
WITH_HDA=""
YML=os.yml

ACTION=$1
shift
CMD=$@


while (( "$#" )); do
  case "$1" in 
        -hda)
            WITH_HDA="$1 $2"
	    shift
        ;;
        -append)
            APPEND_STRING=$2
	    shift
        ;;
        -m)
            MEMORY="$1 $2"
	    shift
        ;;
        -yml)
            YML=$2
	    shift
        ;;
    esac
    shift
done


case "$ACTION" in
#  prepare)
#    docker build -t crunos/qemu "https://github.com/crunos/qemu.git#main" #-f src/Dockerfiles/qemu src/Dockerfiles/
#    docker build -t crunos/linuxkit "https://github.com/crunos/linuxkit.git#main"  #-f src/Dockerfiles/linuxkit src/Dockerfiles/
#    ;;
  build)
    mkdir -p out
    docker run --rm -ti -v $(pwd):$(pwd) -w $(pwd) -v /var/run/docker.sock:/var/run/docker.sock crunos/linuxkit build --docker $YML --dir ./out
    ;;
  run)
	  docker run --rm -ti --name qemu --device /dev/kvm -v $(pwd):$(pwd) -w $(pwd) crunos/qemu $MEMORY -enable-kvm -kernel out/os-kernel -initrd out/os-initrd.img -nographic -device pvpanic -append "$(cat out/os-cmdline) $APPEND_STRING" $WITH_HDA
    ;;
  pkg)
    docker run --rm -ti -v $(pwd):$(pwd) -w $(pwd) -v /var/run/docker.sock:/var/run/docker.sock crunos/linuxkit $CMD
    ;;
  disk)
    docker run --rm -ti -v $(pwd):$(pwd) -w $(pwd) --entrypoint qemu-img crunos/qemu create -f qcow2 $CMD
    ;;
  *)
    echo "build" or "run"
    ;;
esac    
