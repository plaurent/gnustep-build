FROM ubuntu:18.04

RUN apt-get update && apt-get install -y clang build-essential wget git sudo
RUN git clone https://github.com/plaurent/gnustep-build
RUN cp gnustep-build/*.sh .
RUN cp gnustep-build/ubuntu-18.04-clang-6.0-runtime-1.9-ARM/*.sh .
RUN cp gnustep-build/ubuntu-18.04-clang-6.0-runtime-1.9-ARM/testing/Dockerfile .
RUN chmod +x *.sh
RUN /bin/bash -c "./GNUstep-buildon-ubuntu1804_arm.sh"

CMD [ "/bin/bash", "-c", "export PS1=allow_bash_to_run; source ~/.bashrc; ./demo.sh" ]
