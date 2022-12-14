FROM rancher/k3d:5.3.0-dind


# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

WORKDIR /root
ARG API_TOKEN
ARG DT_ENV_URL
COPY k3dconfig.yaml .
COPY deployment.sh .
ADD kubernetes-manifests/ ./kubernetes-manifests
ADD exercice/ ./exercice

ENV PATH="${PATH}:/root"

ENTRYPOINT ["/bin/bash", "./deployment.sh", "--k3d=false" , " --api-token=$API_TOKEN", "--environment-url=$DT_ENV_URL"]
