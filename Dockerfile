FROM ubuntu:16.04

RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install build-essential -y && \
    apt-get install nginx nano acl -y

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
