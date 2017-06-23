# jenkins-headless-webdriver-env-config

## Objective

To configure Jenkins to run in a CentOS machine, being also able to execute acceptance automated tests in headless mode for several browsers in the context of a large enterprise with security/technology restrictions. 

## Details, Constraints and Risks

- Java 8, running acceptance tests with JUnit/Selenium WebDriver
- Browsers that must be tested: Firefox (currently supported), Chrome (to-be), IE (to-be)
- The source code of the Java application (with Selenium Tests) is in another Git Repo
- It is not practical to work directly in the company target machine (VPN does not have good quality)
- Docker is not allowed to run in the infrastructure of the company

## Strategy

- To create a Docker image/container locally (in developer's Mac laptop), and then use scripts (shell, python) in order to configure the environment.
- Validate Jenkins usage in the environment created by Docker
- Use these same scripts to configure the real environment

## How to start?

Create centos-selenium base image (run my Dockerfile)

> cd [Dockerfile directory]
 
> docker build -t selenium .

Create container seleniumg and connect

> docker run -it --name seleniumg -p 8080:8080 selenium bash

Run commands in centos image to prepare to jenkins, in the following order:

> ./webdriver-configuration.sh install_xvfb_and_browsers

> ./webdriver-configuration.sh install_java

> ./webdriver-configuration.sh install_jenkins

> ./webdriver-configuration.sh install_git

> ./webdriver-configuration.sh install_maven

> ./webdriver-configuration.sh prepare_headless

> ./webdriver-configuration.sh test_selenium

> ./webdriver-configuration.sh start_jenkins

## Jenkins config

Since the environment is properly configurated, it should be pretty simple, with no specific Jenkins configuration required.

### Plugins to install

Test Result Analyzer Plugin: in order to present tests in a suitable way.

### Job Config

#### Source code management

Git repo; point to git repo w/ credentials

#### Build

Maven goal: clean package

#### Post-build

Publicate JUnit test report: required to Test Result Analyzer Plugin (above described) to work properly. 

> XML test report: target/surefire-reports/*.xml

> flag checkbox below

# Done?

That's all.

# Appendix

## Useful Docker commands in this context
 
To reconnect to a created container:
> docker start seleniumg 

> docker attach seleniumg

to remove a container:
> docker ps -a (get the name of container - in our case, seleniumg)

> docker rm seleniumg

to remove an image:
> docker images (get the name of image - in our case, selenium)

> docker rmi selenium

to connect to a remote Jenkins machine from a Mac laptop by VPN: 
> ssh [user]@[ip] -o ProxyCommand="nc -X 4 -x 127.0.0.1:1080 %h %p"

to copy installation files to remote Jenkins machine via VPN:
> tar cpf - [file pattern] |  ssh [user]@[ip] -o ProxyCommand="nc -X 4 -x 127.0.0.1:1080 %h %p" "tar xpf - -C /home/[user]/deps" 

to copy files from docker to local directory
> docker cp seleniumc:/deps .

to download dependencies (offline)
> repotrack -a x86_64 -p . [packages]

... and more details in the script files.