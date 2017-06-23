FROM centos:latest
COPY ./webdriver-configuration.sh /
COPY ./webdriver-test.py /
ENV DISPLAY=":1"
ENV PATH="${PATH}:/selenium-drivers"
ENTRYPOINT ["/webdriver-configuration.sh"]
