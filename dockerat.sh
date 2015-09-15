#!/bin/bash
#: Title        : docke_rat
#: Date         : 14.08.2015
#: Author       : "Evgeny Shmarnev" <shmarnev@gmail.com>
#: Version      : 1.1
#: Description  : docke_rat was created for automate process of docker testing
#: Options      : `docker --version`
############################################
# There are five important things:
# 1) you need to be a root to run this script;
# 2) this script accepts one argument  - version of the docker package (e.g. `docker --version` command)
# 3) this script is for basic testing only!;
# 4) you can find all your results in the .log file (see $LOG variable);
# 5) have a lot of fun!

ERRORS=0

#docker version variable:
VERSION="$(docker --version)"

LOG=$(date +"%Y%m%d%H%M".log)

# function that checking status of your command
check() {
    if [ $? -eq 0 ]; then
        echo "PASSED"
    else
        echo "FAILED"
        ERRORS=$[$ERRORS+1]     
    fi
}

check_version() {
    if [ "$1" == "${VERSION}" ]; then
        echo "PASSED"
    else
        echo "FAILED"
        ERRORS=$[$ERRORS+1]     
    fi
}
 

echo "dockerat.sh is now testing Docker on your system, you can find all results in '$LOG' file. Please, be patient..."

echo "Docker testing on '$HOSTNAME' host" > $LOG
echo "" >> $LOG

echo "" >> $LOG
echo "$HOSTNAME:~ # systemctl start docker" >> $LOG
systemctl start docker >> $LOG
echo "test #1 Trying to start Docker on your system..."
check

sleep 2
echo "" >> $LOG
echo "$HOSTNAME:~ # systemctl status docker" >> $LOG
systemctl status docker >> $LOG
echo "test #2 Check status of Docker on your system..."
check

sleep 2
echo "" >> $LOG
echo "$HOSTNAME:~ # systemctl restart docker" >> $LOG
systemctl restart docker >> $LOG
echo "test #3 Check that we can restart Docker on your system..."
check

echo "" >> $LOG
echo "$HOSTNAME:~ # docker --version" >> $LOG
docker --version >> $LOG
echo "test #4 Check Docker version..."
check_version "$@"

echo "" >> $LOG
echo "$HOSTNAME:~ # ip a s | grep -i docker" >> $LOG
ip a s | grep -i docker >> $LOG
echo "test #5 Check that we have docker network interface on your system..."
check 

echo "" >> $LOG
echo "$HOSTNAME:~ # docker ps" >> $LOG
docker ps >> $LOG
echo "test #6 Check the list of running docker containers..."
check
sleep 1

echo "" >> $LOG
echo "$HOSTNAME:~ # docker run opensuse uname -r" >> $LOG
docker run opensuse uname -r &>> $LOG
echo "test #7 Check that we can start a new docker container via 'docker run opensuse uname -r'"
check 

echo "" >> $LOG
echo "$HOSTNAME:~ # docker run opensuse echo 'Hello world!'" >> $LOG
docker run opensuse echo 'Hello world!' >> $LOG
echo "test #8 Check that we can start a new docker container via 'docker run opensuse echo 'Hello world!'"
check 

echo "" >> $LOG
echo "$HOSTNAME:~ # docker run opensuse df -h " >> $LOG
docker run opensuse df -h >> $LOG
echo "test #9 Check that we can start a new docker container via 'docker run opensuse df -h'..."
check 

echo "" >> $LOG
echo "$HOSTNAME:~ # docker run opensuse mount" >> $LOG
docker run opensuse mount >> $LOG
echo "test #10 Check that we can start a new docker container via 'docker run opensuse mount'..."
check

echo "" >> $LOG
echo "$HOSTNAME:~ # docker ps -a" >> $LOG
docker ps -a >> $LOG
echo "test #11 Check that we can see the list of all docker containers on your system..."
check

echo "" >> $LOG
echo "$HOSTNAME:~ # docker images " >> $LOG
docker images >> $LOG
echo "test #12 Check that we can see the list of all docker images on your system..."
check

echo "" >> $LOG
echo "$HOSTNAME:~ # docker info" >> $LOG
docker info >> $LOG
echo "test #13 Check docker info..."
check

echo ""
if [ $ERRORS -eq 0 ]; then
echo "All Tests are PASSED, check your results in '$LOG' file"
    else
echo "One (or more) tests is FAILED, please check '$LOG' for additional information"
    fi

echo "" 

echo "Do you wish to destory all Docker images and containers on your system? (Please choose  1 - for Yes, and 2 - for No)"
select yn in "Yes" "No"; do
    case $yn in 
        Yes ) echo ""; echo "Deleting your containers: "; echo ""; docker rm -f $(docker ps -a -q) && docker rmi $(docker images -q) &> /dev/null; break;;
        No  ) exit;;
    esac
done
