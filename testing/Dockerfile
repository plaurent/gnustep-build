FROM ubuntu:19.04

RUN apt-get update && apt-get install -y clang build-essential wget git sudo
RUN git clone https://github.com/plaurent/gnustep-build-ubuntu; chmod +x gnustep-build-ubuntu/*.sh; cp gnustep-build-ubuntu/*.sh .
RUN /bin/bash -c ./GNUstep-buildon-ubuntu1904.sh
#RUN /bin/bash -c ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh; ./demo.sh"

CMD [ "/bin/bash", "-c". "/usr/GNUstep/System/Library/Makefiles/GNUstep.sh; ./demo.sh" ]
