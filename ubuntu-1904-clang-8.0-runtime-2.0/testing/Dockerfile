FROM ubuntu:19.04

RUN apt-get update && apt-get install -y clang build-essential wget git sudo
RUN git clone https://github.com/plaurent/gnustep-build
RUN cp gnustep-build/*.sh .
RUN cp gnustep-build/ubuntu-19.04-clang-8.0-runtime-2.0/*.sh .
RUN cp gnustep-build/ubuntu-19.04-clang-8.0-runtime-2.0/testing/Dockerfile .
RUN chmod +x *.sh
RUN /bin/bash -c "./GNUstep-buildon-ubuntu1904.sh"

CMD [ "/bin/bash", "-c", "whoami; . /usr/GNUstep/System/Library/Makefiles/GNUstep.sh; ./demo.sh" ]
