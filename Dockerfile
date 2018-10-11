FROM devops.nxp.com/face-recognition-server-x86:2018-4-18

#RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

RUN mkdir -p /app

ENV http_proxy="http://wbi\nxf42681:Welcome%402017@apac.nics.nxp.com:8080" 
ENV ftp_proxy="http://wbi\nxf42681:Welcome%402017@apac.nics.nxp.com:8080" 
ENV https_proxy="http://wbi\nxf42681:Welcome%402017@apac.nics.nxp.com:8080"
WORKDIR /app

RUN apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu 
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN pip install keras_applications mock enum34 
RUN apt-get install -y pkg-config zip g++ zlib1g-dev unzip python wget curl autoconf automake libtool maven
ENV GIT_SSL_NO_VERIFY=1

RUN git clone https://github.com/google/protobuf.git
WORKDIR protobuf
RUN git checkout -b v3.5 origin/3.5.x
RUN ./autogen.sh

RUN ./configure --prefix=/usr/local
RUN make -j8
RUN make install
WORKDIR java
ENV PROTOC=/app/protobuf

WORKDIR /app
RUN mkdir bazel
WORKDIR bazel
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.16.1/bazel-0.16.1-installer-linux-x86_64.sh
RUN chmod +x bazel-0.16.1-installer-linux-x86_64.sh
RUN ./bazel-0.16.1-installer-linux-x86_64.sh 

WORKDIR /app
RUN mkdir libpython-arm64/
RUN wget https://blueprints.launchpad.net/ubuntu/+source/python2.7/2.7.11-7ubuntu1/+build/9589511/+files/libpython2.7-dev_2.7.11-7ubuntu1_arm64.deb
RUN dpkg-deb -x  libpython2.7-dev_2.7.11-7ubuntu1_arm64.deb libpython-arm64/
RUN cp -r libpython-arm64/usr/include/python2.7 /usr/aarch64-linux-gnu/include/
RUN cp /usr/aarch64-linux-gnu/include/python2.7/pyconfig.h /usr/include/python2.7/
RUN cp -r libpython-arm64/usr/include/aarch64-linux-gnu /usr/include
RUN cp libpython-arm64/usr/include/python2.7/* /usr/aarch64-linux-gnu/include/python2.7/
RUN cp  libpython-arm64/usr/include/aarch64-linux-gnu/python2.7/* /usr/include/python2.7/
 
WORKDIR /app
RUN git clone https://github.com/tensorflow/tensorflow	
WORKDIR tensorflow
RUN git checkout -b r1.10 origin/r1.10
RUN sed -i '$a\new_local_repository(\n     name = "aarch64_compiler",\n     path = "/",\n     build_file = "aarch64_compiler.BUILD",\n)' WORKSPACE
COPY aarch64_compiler.BUILD .
RUN mkdir -p tools/aarch64_compiler

WORKDIR /app/tensorflow/tools/aarch64_compiler
COPY BUILD .
COPY CROSSTOOL .

WORKDIR /app/tensorflow
RUN sh -c '/bin/echo -e "\n\n\nn\nn\nn\nn\nn\nn\nn\nn\nn\nn\nn\nn\n-march=arm\nn" ./configure'

RUN  bazel build -c opt //tensorflow/tools/pip_package:build_pip_package --cpu=aarch64 --crosstool_top=//tools/aarch64_compiler:toolchain --host_crosstool_top=@bazel_tools//tools/cpp:toolchain --verbose_failures
RUN mkdir -p tensorflow_pkg
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package tensorflow_pkg/

WORKDIR /app/tensorflow/tensorflow_pkg
RUN mv *.whl  tensorflow-1.10.0-cp27-cp27mu-linux_aarch64.whl 
