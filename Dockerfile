FROM ubuntu:20.04

ARG CONDA_VERSION=py39_23.10.0-1
ARG CONDA_ENV=base
ARG PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple


RUN apt-get clean && apt-get update && \
    apt-get install -y\
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN set -x && \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh" && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    mkdir -p /opt && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

ENV DATA_DIR=/tmp/app-data
ENV PATH=/opt/conda/bin:$PATH
ENV PYTHONPATH=/code:$PYTHONPATH

WORKDIR /code
COPY . .
# RUN conda run pip install --name ${CONDA_ENV} -f environment.yml -c conda-forge && rm environment.yml
RUN conda run -n ${CONDA_ENV} pip install -r requirements.txt -i ${PIP_INDEX_URL} && \
    rm requirements.txt

ENTRYPOINT ["/bin/bash"]
