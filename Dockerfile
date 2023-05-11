#DOCKERFILE FOR SWORD DOCKER IMAGE

FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y vim wget git build-essential python2.7 python-pip
RUN apt-get install -y python-dev autotools-dev libicu-dev libbz2-dev checkinstall zlib1g-dev libssl-dev openssl

ENV SWORD_LIBS=/sword/libs

#Cmake 3.4.3
WORKDIR $SWORD_LIBS
RUN wget https://github.com/Kitware/CMake/archive/refs/tags/v3.4.3.tar.gz
RUN tar -xzvf v3.4.3.tar.gz
RUN rm v3.4.3.tar.gz
WORKDIR CMake-3.4.3/
RUN ./bootstrap
RUN make
RUN make install

#glpk 4.61
WORKDIR $SWORD_LIBS
RUN wget http://ftp.gnu.org/gnu/glpk/glpk-4.61.tar.gz
RUN tar -xf glpk-4.61.tar.gz
RUN rm glpk-4.61.tar.gz
WORKDIR glpk-4.61
RUN ./configure
RUN make
RUN make check
RUN make install

#boost 1.58
WORKDIR $SWORD_LIBS
RUN wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2
RUN tar --bzip2 -xf boost_1_58_0.tar.bz2
RUN rm boost_1_58_0.tar.bz2
WORKDIR boost_1_58_0
RUN ./bootstrap.sh
RUN ./b2;
RUN ./b2 install;
RUN ldconfig

#Ninja
RUN apt-get install -y ninja-build

#LLVM/clang 6.0.0

#llvm
WORKDIR $SWORD_LIBS
RUN wget https://releases.llvm.org/6.0.0/llvm-6.0.0.src.tar.xz
RUN tar -xf llvm-6.0.0.src.tar.xz
RUN rm llvm-6.0.0.src.tar.xz

WORKDIR llvm-6.0.0.src

#llvm-clang
WORKDIR tools
RUN wget https://releases.llvm.org/6.0.0/cfe-6.0.0.src.tar.xz
RUN tar -xf cfe-6.0.0.src.tar.xz
RUN rm cfe-6.0.0.src.tar.xz
RUN mv cfe-6.0.0.src/ clang

#llvm-clang-tools-extra
WORKDIR clang/tools
RUN wget https://releases.llvm.org/6.0.0/clang-tools-extra-6.0.0.src.tar.xz
RUN tar -xf clang-tools-extra-6.0.0.src.tar.xz
RUN rm clang-tools-extra-6.0.0.src.tar.xz
RUN mv clang-tools-extra-6.0.0.src/ extra

WORKDIR $SWORD_LIBS/llvm-6.0.0.src

#llvm-lld
WORKDIR tools
RUN wget https://releases.llvm.org/6.0.0/lld-6.0.0.src.tar.xz
RUN tar -xf lld-6.0.0.src.tar.xz
RUN rm lld-6.0.0.src.tar.xz
RUN mv lld-6.0.0.src/ lld

WORKDIR $SWORD_LIBS/llvm-6.0.0.src

#libcxx
WORKDIR projects
RUN wget https://releases.llvm.org/6.0.0/libcxx-6.0.0.src.tar.xz
RUN tar -xf libcxx-6.0.0.src.tar.xz
RUN rm libcxx-6.0.0.src.tar.xz
RUN mv libcxx-6.0.0.src/ libcxx

#libcxxabi
RUN wget https://releases.llvm.org/6.0.0/libcxxabi-6.0.0.src.tar.xz
RUN tar -xf libcxxabi-6.0.0.src.tar.xz
RUN rm libcxxabi-6.0.0.src.tar.xz
RUN mv libcxxabi-6.0.0.src/ libcxxabi

WORKDIR $SWORD_LIBS/llvm-6.0.0.src

#Build llvm and all its dependencies
WORKDIR build
RUN cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..
RUN ninja -j$(nproc) -l$(nproc)
RUN ninja install

#openmp 6.0.0
WORKDIR $SWORD_LIBS
RUN wget https://releases.llvm.org/6.0.0/openmp-6.0.0.src.tar.xz
RUN tar -xf openmp-6.0.0.src.tar.xz
RUN rm openmp-6.0.0.src.tar.xz
RUN mv openmp-6.0.0.src openmp
WORKDIR openmp/runtime

ENV OPENMP_INSTALL=/sword/usr
RUN cmake -G Ninja  -D CMAKE_C_COMPILER=clang  -D CMAKE_CXX_COMPILER=clang++  -D CMAKE_BUILD_TYPE=Release  -D CMAKE_INSTALL_PREFIX:PATH=$OPENMP_INSTALL  ..
RUN ninja -j$(nproc) -l$(nproc)
RUN ninja install

#sword:latest
WORKDIR $SWORD_LIBS
RUN git clone https://github.com/PRUNERS/sword.git sword

ENV SWORD_INSTALL=/sword/usr

WORKDIR sword/build
RUN cmake -G Ninja -D CMAKE_C_COMPILER=/usr/local/bin/clang -D CMAKE_CXX_COMPILER=/usr/local/bin/clang++ -D CMAKE_BUILD_TYPE=Release -D OMP_PREFIX:PATH=$OPENMP_INSTALL -D CMAKE_INSTALL_PREFIX:PATH=${SWORD_INSTALL} -D COMPRESSION=LZO ..
RUN ninja -j$(nproc) -l$(nproc)
RUN ninja install

RUN echo 'export PATH=$SWORD_INSTALL/bin:$PATH' >> ~/.bashrc

WORKDIR /