FROM        ubuntu:latest
MAINTAINER  aramirez@kenzan.com
EXPOSE      8080 3000 3001 3002 3003 3004 9000 9001 9002 9002 9004

COPY    ./bin                    ~/million-song-library/bin
COPY    ./msl-pages              ~/million-song-library/msl-pages
COPY    ./server                 ~/million-song-library/server
COPY    ./docs                   ~/million-song-library/docs

WORKDIR ~/million-song-library/msl-pages
RUN     echo -e "\n\033[0;35mCOMPLETED LOADING CONTENTS..................\033[0m\n"

# INSTALLING SOME OS BASIC DEPS
RUN     echo -e "\n\033[0;35mINSTALLING BASIC OS ........................\033[0m\n"
RUN     apt-get update
RUN     apt-get install -y software-properties-common libpng-dev sudo python default-jdk
RUN     sudo apt-get -y install wget git-core curl

# INSTALL JAVA
RUN     cd ../bin/provision && sudo chmod +x java-setup.sh && bash java-setup.sh

# RUNNING SETUP SCRIPT
RUN     echo -e "\n\033[0;35mRUNNING SETUP SCRIPT........................\033[0m\n"
RUN     cd ../bin/provision && sudo chmod +x validate-requirements.sh
RUN     cd ../bin/provision && sudo chmod +x basic-dep-setup.sh && bash ./basic-dep-setup.sh
RUN     cd ../bin && sudo chmod +x setup.sh && bash setup.sh -n -s -v -y

# INSTALL TOMCAT
RUN     echo -e "\n\033[0;35mINSTALLING TOMCAT ........................\033[0m\n"
RUN     sudo apt-get install -y tomcat7
RUN     sudo apt-get install -y tomcat7-docs tomcat7-admin tomcat7-examples
COPY    server/eureka.war       /var/lib/tomcat7/webapps

ENTRYPOINT ["/bin/bash"]