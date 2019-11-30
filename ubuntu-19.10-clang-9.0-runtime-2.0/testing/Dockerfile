FROM ubuntu:19.10

RUN apt-get update && apt-get install -y git sudo
RUN git clone https://github.com/plaurent/gnustep-build
RUN cp gnustep-build/*.sh .
RUN cp gnustep-build/ubuntu-19.10-clang-9.0-runtime-2.0/*.sh .
RUN cp gnustep-build/ubuntu-19.10-clang-9.0-runtime-2.0/testing/Dockerfile .
RUN chmod +x *.sh
RUN /bin/bash -c "./GNUstep-buildon-ubuntu1910.sh"

CMD [ "/bin/bash" ] #, "-c", "export PS1=allow_bash_to_run; source ~/.bashrc; ./demo.sh" ]
