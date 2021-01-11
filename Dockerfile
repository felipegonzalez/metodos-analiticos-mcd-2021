FROM rocker/verse:4.0.3
RUN cat /etc/os-release

ENV WORKON_HOME /opt/virtualenvs
ENV PYTHON_VENV_PATH $WORKON_HOME/ma_env
ENV SPARK_VERSION 3.0.0
ENV SPARKLYR_VERSION 1.5.2

RUN apt-get update \
	&& apt-get install -y libudunits2-dev libcurl4-openssl-dev \
	   libxml2-dev git zlib1g-dev qpdf

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential python3 python3-dev python3-wheel \
	libpython3-dev python3-virtualenv \
        python3-pip libssl-dev libffi-dev apt-utils

## Prepara environment de python
RUN python3 -m virtualenv --python=/usr/bin/python3 ${PYTHON_VENV_PATH}
RUN chown -R rstudio:rstudio ${WORKON_HOME}
ENV PATH ${PYTHON_VENV_PATH}/bin:${PATH}
## And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron && \
    echo "WORKON_HOME=${WORKON_HOME}" >> /usr/local/lib/R/etc/Renviron && \
    echo "RETICULATE_PYTHON_ENV=${PYTHON_VENV_PATH}" >> /usr/local/lib/R/etc/Renviron

## Because reticulate hardwires these PATHs
RUN ln -s ${PYTHON_VENV_PATH}/bin/pip /usr/local/bin/pip && \
    ln -s ${PYTHON_VENV_PATH}/bin/virtualenv /usr/local/bin/virtualenv
RUN chmod -R a+x ${PYTHON_VENV_PATH}

# instalar sparklyr
RUN r -e 'devtools::install_version("sparklyr", version = Sys.getenv("SPARKLYR_VERSION"))' 

USER rstudio
RUN r -e 'sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), verbose = TRUE)'
USER root

#COPY resources/arrow_install.sh /root/.local/arrow_install.sh
#RUN sh /root/.local/arrow_install.sh
# Install arrow R package
#RUN install2.r --error --deps TRUE arrow
#RUN r -e 'arrow::install_arrow()'

RUN .${PYTHON_VENV_PATH}/bin/activate && \
 pip install --upgrade setuptools==51.1.* && \
 pip install --upgrade tensorflow==2.3.0 \
     keras==2.3.* \ 
     requests \
     scipy==1.4.1 \
     pandas==1.1.5 \
     h5py==2.10.0 \
     scikit-learn==0.24


# Install microbenchmark
RUN install2.r --error --deps TRUE microbenchmark
COPY scripts_pruebas/spark_prueba.R /root/.local/spark_prueba.R


RUN install2.r --error \
     reticulate tensorflow  keras \ 
     graphframes \
     arules arulesViz \
     tidygraph \
     tidymodels 

RUN install2.r --error tm text2vec textrank \
     tidytext textreuse \
     ggraph here png

RUN install2.r --error patchwork

RUN r -e 'devtools::install_github("rstudio/bookdown", ref = "92c59d32ecb46aa8cb7150ba1139621705e23901")'
