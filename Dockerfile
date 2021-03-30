FROM alpine:3.13 as compile 
WORKDIR /root

RUN apk add --no-cache alpine-sdk gcc musl-dev git cmake
RUN git clone https://github.com/taosdata/TDengine.git
RUN ls -a
RUN mkdir build && cd build 
RUN export VERBOSE=defined
RUN cmake ../TDengine 
RUN cmake --build .


FROM alpine:3.13 as base
WORKDIR /app 

COPY --from=compile /root/build/build/bin/* /usr/bin/
COPY --from=compile /root/build/build/lib/libtaos.so /usr/lib/
COPY --from=compile /root/packaging/cfg/taos.cfg /etc/taos/

RUN echo "charset UTF-8" >> /etc/taos/taos.cfg
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib"
ENV LC_CTYPE="en_US.UTF-8"

# origin blog missing this
ENV LC_ALL="C"

EXPOSE 6030 6031 6032 6033 6034 6035 6036 6037 6038 6039 6040 6041 6042
CMD ["taosd"]
VOLUME [ "/var/lib/taos", "/var/log/taos","/etc/taos/" ]