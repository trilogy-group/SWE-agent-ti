FROM python:3.11

ARG TARGETARCH

# Install third party tools
RUN apt-get update && \
    apt-get install -y bash gcc git jq wget g++ make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install OpenJDK-11
RUN apt-get update && \
    apt-get install -y openjdk-17-jre-headless && \
    apt-get clean;

# Initialize git
RUN git config --global user.email "sweagent@pnlp.org"
RUN git config --global user.name "sweagent"

# Environment variables
ENV ROOT='/dev/'
RUN prompt() { echo " > "; };
ENV PS1="> "

# Create file for tracking edits, test patch
RUN touch /root/files_to_edit.txt
RUN touch /root/test.patch

# add ls file indicator
RUN echo "alias ls='ls -F'" >> /root/.bashrc

# Install miniconda
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
COPY docker/getconda.sh .
RUN bash getconda.sh ${TARGETARCH} \
    && rm getconda.sh \
    && mkdir /root/.conda \
    && bash miniconda.sh -b \
    && rm -f miniconda.sh
RUN conda --version \
    && conda init bash \
    && conda config --append channels conda-forge

# Install PMD
RUN wget https://github.com/pmd/pmd/releases/download/pmd_releases/7.1.0/pmd-dist-7.1.0-bin.zip
RUN unzip pmd-dist-7.1.0-bin.zip -d /root
ENV PATH="/root/pmd-bin-7.1.0/bin:${PATH}"
ARG PATH="/root/pmd-bin-7.1.0/bin:${PATH}"

# Install python packages
COPY docker/requirements.txt /root/requirements.txt
RUN pip install -r /root/requirements.txt

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get install git-lfs

WORKDIR /

CMD ["/bin/bash"]