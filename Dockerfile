FROM scratch

ADD rootfs.gz /

ENTRYPOINT ["/bin/sh"]
CMD [""]
