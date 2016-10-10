# This image provides a base for building and running java applications.
# It builds using maven and runs the resulting artifacts on Tomcat7.0.72

FROM openshift/base-centos7

MAINTAINER Yilisa <915961521@qq.com>

EXPOSE 8080

ENV TOMCAT_VERSION=7.0.72 \
    CATALINA_HOME=/usr/local/tomcat \
    PATH=$CATALINA_HOME/bin:$PATH  


LABEL io.k8s.description="Platform for building and running Java applications on Tomcat7.0.72" \
      io.k8s.display-name="Tomcat7.0.72" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,binary,tomcat7,java7" \
      io.openshift.s2i.destination="/opt/s2i/destination" 

ADD apache-tomcat-7.0.72.tar.gz /usr/local/

# Install Tomcat7.0.72
RUN INSTALL_PKGS="bc java-1.7.0-openjdk java-1.7.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    mv /usr/local/apache-tomcat-7.0.72 $CATALINA_HOME && \
    rm -fr $CATALINA_HOME/webapps/* && \  
    mkdir -p /opt/s2i/destination

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH (/usr/local/s2i)
COPY ./.s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 $CATALINA_HOME && chown -R 1001:0 $HOME && \
    chmod -R ug+rw $CATALINA_HOME && \ 
    chmod -R g+rw /opt/s2i/destination && \
    chown -R 1001:1001 $HOME

USER 1001

CMD $STI_SCRIPTS_PATH/usage
