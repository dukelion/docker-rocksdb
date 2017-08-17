FROM golang:1.8-alpine

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories && \
    echo "@community http://nl.alpinelinux.org/alpine/edge/community" >>/etc/apk/repositories
RUN apk add --update --no-cache build-base linux-headers git cmake bash #wget mercurial g++ autoconf libgflags-dev cmake  bash jemalloc perl 
RUN apk add --update --no-cache zlib zlib-dev bzip2 bzip2-dev snappy snappy-dev lz4 lz4-dev zstd@community zstd-dev@community jemalloc jemalloc-dev libtbb-dev@testing libtbb@testing

# installing latest gflags
RUN cd /tmp && \
    git clone https://github.com/gflags/gflags.git && \
    cd gflags && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_SHARED_LIBS=1 -DGFLAGS_INSTALL_SHARED_LIBS=1 .. && \
    make install && \
    make install DESTDIR=/dist

# Compile Rocksdb
RUN cd /tmp && \
    git clone https://github.com/facebook/rocksdb.git && \
    cd rocksdb && \
    git checkout v4.13.5 && \
    make static_lib && \
    make tools
#gather artifacts
RUN cd /tmp/rocksdb && \
    mkdir -p /dist/usr/local/rocksdb/lib && \
    mkdir -p /dist/usr/local/rocksdb/include && \
    mkdir -p /dist/usr/bin && \
    mkdir -p /dist/usr/lib && \
    mkdir -p /dist/usr/include && \
    apk add --update --no-cache coreutils && \
    make install-static INSTALL_PATH=/dist/usr/ && \
    make install-shared INSTALL_PATH=/dist/usr/ && \
    cp sst_dump /dist/usr/bin/ && \
#    cp rocksdb_dump /dist/usr/bin/ && \
#    cp rocksdb_undump /dist/usr/bin/ && \
#    cp db_repl_stress /dist/usr/bin/ && \
#    cp db_sanity_test /dist/usr/bin/ && \
#    cp db_stress /dist/usr/bin/ && \
#    cp write_stress /dist/usr/bin/ && \
    cp ldb /dist/usr/bin/ 

#Cleanup
RUN rm -R /tmp/gflags/ && \
    rm -R /tmp/rocksdb/


FROM alpine:3.6
MAINTAINER unoexperto <unoexperto.support@mailnull.com>
RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories && \
    echo "@community http://nl.alpinelinux.org/alpine/edge/community" >>/etc/apk/repositories
RUN apk add --update --no-cache zlib bzip2 snappy lz4 zstd@community jemalloc libtbb@testing bzip2-dev zlib-dev lz4-dev
COPY --from=0 /dist/* /

