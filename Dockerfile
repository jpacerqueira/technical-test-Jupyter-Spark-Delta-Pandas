FROM ubuntu:18.04

RUN apt-get update -y && apt-get install -y apt-utils \
    sudo
RUN apt-get upgrade -y
RUN \
    groupadd -g 999 notebookuser && useradd -u 999 -g notebookuser -G sudo -m -s /bin/bash notebookuser && \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "notebookuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the notebookuser user!" && \
    echo "notebookuser user:";  su - notebookuser -c id

RUN export DEBIAN_FRONTEND=noninteractive ; \
    apt-get update -y && apt-get install -y curl \
    tzdata \
    net-tools \
    iptables \
    iptables-persistent \
    wget \
    zip \
    unzip \
    tar \
    bzip2 \
    python-qt4 \
    python-pyside \
    python-pip \
    python3-pip \
    python3-pyqt5 \
    vim \
    software-properties-common

ADD library_tools/*.sh /home/notebookuser/

RUN chmod 777 /home/notebookuser/*.sh

CMD mkdir -p /home/notebookuser/java/

ADD java_tools/*.* /home/notebookuser/java/

RUN chmod 777 /home/notebookuser/java/*.sh

CMD mkdir -p  /home/notebookuser/notebooks/data ; \
    mkdir -p  /home/notebookuser/notebooks/test_exercise/data/delta_business_terms ; \
    mkdir -p  /home/notebookuser/notebooks/test_exercise/data/delta_business_terms ; \
    mkdir -p  /home/notebookuser/notebooks/test_exercise/data/delta_real_estate_term_definitions ; \
    mkdir -p  /home/notebookuser/notebooks/test_exercise/data/delta_terms_words_ngrams_real_estate ; \
    mkdir -p  /home/notebookuser/notebooks/test_exercise/data/terms_words_mortgages

ADD notebooks/*.* /home/notebookuser/notebooks/
ADD notebooks/data/*.*  /home/notebookuser/notebooks/data/
#
ADD notebooks/test_exercise/*.*  /home/notebookuser/notebooks/test_exercise/
ADD notebooks/test_exercise/data/delta_business_terms/*.*  /home/notebookuser/notebooks/test_exercise/data/delta_business_terms/
ADD notebooks/test_exercise/data/delta_real_estate_term_definitions/*.*  /home/notebookuser/notebooks/test_exercise/data/delta_real_estate_term_definitions/
ADD notebooks/test_exercise/data/delta_terms_words_ngrams_real_estate/*.*  /home/notebookuser/notebooks/test_exercise/data/delta_terms_words_ngrams_real_estate/
ADD notebooks/test_exercise/data/terms_words_mortgages/*.*  /home/notebookuser/notebooks/test_exercise/data/terms_words_mortgages/

ADD setup-container-tools.sh /home/notebookuser/setup-container-tools.sh

RUN chmod 777 /home/notebookuser/*.sh

RUN chown notebookuser:notebookuser -R /home/notebookuser

RUN ln -fs /usr/share/zoneinfo/GMT /etc/localtime

EXPOSE 9003/tcp
##EXPOSE 54321/tcp
RUN (echo "20 6 * * * notebookuser bash -x /home/notebookuser/notebooks/daily-automation-notebook.sh" > /etc/cron.daily/notebooks-jupyter ; chmod 755 /etc/cron.daily/notebooks-jupyter )

RUN export DEBIAN_FRONTEND=interactive

USER notebookuser

CMD export HOME=/home/notebookuser

RUN (echo "{ \n }" > $HOME/notebooks/Analyser-CVs-PDF-YYYYMMDD.ipynb)

# Anaconda python and R package installer
CMD  export HOME=/home/notebookuser ; cd $HOME ; \
     sleep 9 ; \
     bash -x $HOME/setup-container-tools.sh .sh ; \
     sudo chown notebookuser:notebookuser -R $HOME ; \
     bash -x $HOME/library_tools/install-jupyter-support-packs.sh ; \
     bash -x $HOME/start-jupyter.sh ; \
     conda install --quiet --yes \
     'r-base=3.5.1' \
     'r-rodbc=1.3*' \
     'unixodbc=2.3.*' \
     'r-irkernel=0.8*' \
     'r-plyr=1.8*' \
     'r-devtools=1.13*' \
     'r-tidyverse=1.2*' \
     'r-shiny=1.2*' \
     'r-rmarkdown=1.11*' \
     'r-forecast=8.2*' \
     'r-rsqlite=2.1*' \
     'r-reshape2=1.4*' \
     'r-nycflights13=1.0*' \
     'r-caret=6.0*' \
     'r-rcurl=1.95*' \
     'r-crayon=1.3*' \
     'r-randomforest=4.6*' \
     'r-htmltools=0.3*' \
     'r-sparklyr=0.9*' \
     'r-htmlwidgets=1.2*' \
     'r-hexbin=1.27*' && \
     conda clean -tipsy && \
     fix-permissions $HOME ; \ 
     bash -x $HOME/stop-jupyter.sh ; \
     sleep infinity
#
