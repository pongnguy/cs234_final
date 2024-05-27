
FROM dzcr/cs234-final:base

ENV DEBIAN_FRONTEND=noninteractive

#RUN --mount=type=cache,target=/root/.cache/pip \
#  venv/bin/pip install -e .

RUN --mount=type=secret,id=gcloud-serviceaccount \
    mkdir -p /root/.config/gcloud/ && \
#    cp /run/secrets/gcloud-serviceaccount /root/.config/gcloud/serviceaccount.json
    gcloud auth login --cred-file=/run/secrets/gcloud-serviceaccount

RUN gcloud init
RUN gcloud iam service-accounts keys create /root/.config/gcloud/serviceaccount.json --iam-account=cloudstorage@flock-zerobudget.iam.gserviceaccount.com

RUN gcloud auth activate-service-account --key-file=/root/.config/gcloud/serviceaccount.json
ENV GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/serviceaccount.json
#RUN gcloud auth application-default login
#RUN gcloud config set project flock-zerobudget && \
#    gcloud auth application-default set-quota-project flock-zerobudget

##RUN --mount=type=secret,id=gcloud-adc \
##    mkdir -p /root/.config/gcloud/ && \
##    cp /run/secrets/gcloud-adc /root/.config/gcloud/application_default_credentials.json


EXPOSE 22

RUN apt-get install tini
ENTRYPOINT ["/tini", "--"]
CMD ["/usr/sbin/sshd", "-D"]
#ENTRYPOINT ["/usr/sbin/sshd","-D"]
#CMD ["/mnt/host/cs234_final/venv/bin/python", "jupyter", "lab", "--allow-root", "--autoreload", "--no-browser"]