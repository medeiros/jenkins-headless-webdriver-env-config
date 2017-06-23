#!/bin/bash
set -e

geckodriver_url=https://github.com/mozilla/geckodriver/releases/download/v0.17.0/geckodriver-v0.17.0-linux64.tar.gz
selenium_driver_dir=./selenium-drivers
epel_rpm_url=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

install_if_not_exists() {
    rpm -qa | grep -qw $1 || (yum -y update && yum -y install $1 && yum clean all)
    return 0
}

install_if_not_exists_rpm() {
    url=$2
    rpm -qa | grep -qw $1 || (wget $2 && yum -y install `echo ${url##*/}`  && yum clean all)
    return 0
}

if [ "$1" = 'install_xvfb_and_browsers' ]; then
    install_if_not_exists xorg-x11-server-Xvfb
    install_if_not_exists firefox

    # geckodriver
    if [ ! -d selenium-drivers ]; then
        mkdir selenium-drivers
        install_if_not_exists wget
        wget -qO- $geckodriver_url -O - | tar xvz -C $selenium_driver_dir
        echo ---
        echo [geckodriver] Add to the PATH variable: `readlink -f $selenium_driver_dir`
        echo ---
    fi
elif [ "$1" = 'install_java' ]; then
    install_if_not_exists java

    echo ---
    echo java installed at: `whereis java`
    echo ---
elif [ "$1" = 'install_jenkins' ]; then
    rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

    install_if_not_exists wget
    wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo

    install_if_not_exists jenkins

    echo ---
    echo jenkins installed at: `whereis jenkins | cut -d':' -f2`
    echo ---
elif [ "$1" = 'install_git' ]; then
    install_if_not_exists git

    echo ---
    echo git installed at: `whereis git`
    echo ---
elif [ "$1" = 'install_maven' ]; then
    install_if_not_exists maven

    echo ---
    echo maven installed at: `whereis maven`
    echo ---
elif [ "$1" = 'prepare_headless' ]; then
    Xvfb :1 -screen 0 '1024x768x24' -ac &> /xvfb.log &
    dbus-uuidgen > /var/lib/dbus/machine-id
    echo ---
    echo please add DISPLAY variable in env, with the following command:
    echo export DISPLAY=:1
    echo ---
elif [ "$1" = 'test_selenium' ]; then
    # epel package is pre-requirement for python-pip
    install_if_not_exists wget
    install_if_not_exists_rpm epel $epel_rpm_url
    install_if_not_exists python-pip

    pip install --upgrade pip
    pip install selenium                            # python install selenium for testing purposes
    python webdriver-test.py -u $2                  # script python to validate selenium
elif [ "$1" = 'start_jenkins' ]; then
    nohup java -jar `whereis jenkins | cut -d':' -f2`/jenkins.war > /var/log/jenkins/jenkins.log 2>&1 &
    ps aux | grep jenkins
else
    echo "Usage: $0 [install_xvfb_and_browsers|install_java|install_jenkins|install_git|install_maven|prepare_headless|test_selenium <domain>|start_jenkins]"
fi

exec "$@"
