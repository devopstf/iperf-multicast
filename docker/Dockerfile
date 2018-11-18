# Implements a simple iperf image on alpine linux.
#
# Installs bash for use in the startup script and rsyslog
# for use in outputting test reports.
#
FROM alpine:3.1
MAINTAINER DevOpsTF <devopstenerife@gmail.com>

ADD run_iperf.sh /bin/
ADD sample.mp4 /data/

RUN apk update &&\
 apk add bash &&\
 apk add rsyslog &&\
 apk add iperf

EXPOSE 5001

# command line arguments passed in the CMD at runtime
# will be passed through to iperf
ENTRYPOINT ["/bin/run_iperf.sh"]
