FROM ubuntu:20.04

RUN mkdir -p /var/log/nginx/ /etc/nginx /var/lib/nginx
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get install -f -y  git \
  sshpass \
  openssh-server \
  ca-certificates \
  libc6-dev \
  libpcre3-dev \
  libpcre2-dev \
  perl \
  make \
  build-essential \
  libpcre3 \
  libpcre3-dev \
  gcc \
  g++ \
  libffi-dev \
  libssl-dev --no-install-recommends && \
  apt-get clean 
RUN apt install -y zlib1g=1:1.2.11.dfsg-2ubuntu1.3 --allow-downgrades && apt install -y  zlib1g-dev=1:1.2.11.dfsg-2ubuntu1.3 --allow-downgrades

COPY nginx /tmp/nginx
 
RUN cd /tmp/nginx/nginx-1.22.0 &&  ./configure  --prefix=/usr/share/nginx \
--conf-path=/etc/nginx/nginx.conf \
--http-log-path=/var/log/nginx/access.log \
--error-log-path=/var/log/nginx/error.log \
--lock-path=/var/lock/nginx.lock \
--pid-path=/run/nginx.pid \
--modules-path=/usr/lib/nginx/modules \
--http-proxy-temp-path=/var/lib/nginx/proxy \
 --add-module=/tmp/nginx/nginx-aws-auth-module \
--with-http_auth_request_module \
--with-stream \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
 --with-http_ssl_module \
 --with-debug --with-compat --with-http_slice_module --with-threads --with-http_addition_module --with-file-aio 
RUN cd /tmp/nginx/nginx-1.22.0/ && make 
RUN cd /tmp/nginx/nginx-1.22.0/ && make install 

VOLUME /etc/nginx/
RUN    ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log  
RUN ln -s /usr/share/nginx/sbin/nginx /usr/sbin/nginx

EXPOSE 80
EXPOSE 443
EXPOSE 8080

STOPSIGNAL SIGQUIT

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
