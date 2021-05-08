FROM ubuntu:20.04

RUN uname -a
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /dev/timezone
RUN apt-get update && apt-get install -y git sudo
RUN git clone https://github.com/plaurent/gnustep-build
RUN cp gnustep-build/*.sh .
RUN cp gnustep-build/ubuntu-20.04-clang-10.0-runtime-2.0/*.sh .
RUN cp gnustep-build/ubuntu-20.04-clang-10.0-runtime-2.0/testing/Dockerfile .
RUN chmod +x *.sh

CMD [ "/bin/bash", "-c", "export PS1=allow_bash_to_run; source ~/.bashrc; ./libobjc2-teston-ubuntu2004.sh" ]
