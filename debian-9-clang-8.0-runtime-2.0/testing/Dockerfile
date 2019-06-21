FROM debian:9

RUN apt-get update && apt-get install -y clang build-essential wget git sudo
RUN git clone https://github.com/plaurent/gnustep-build --branch add_debian_clang8_repository
RUN cp gnustep-build/*.sh .
RUN cp gnustep-build/debian-9-clang-8.0-runtime-2.0/*.sh .
RUN cp gnustep-build/debian-9-clang-8.0-runtime-2.0/testing/Dockerfile .
RUN chmod +x *.sh
RUN /bin/bash -c "./GNUstep-buildon-debian9.sh"

CMD [ "/bin/bash", "-c", "export PS1=allow_bash_to_run; source ~/.bashrc; ./demo.sh" ]
