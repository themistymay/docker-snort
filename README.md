# docker-snort

=======
Builds a snort base image

=======
```bash
 docker run -it --net=host {ID} -A console -q -u snort -g snort -c /etc/snort/snort.conf -i eth0
```
