FROM wearefrank/zaakbrug-base:5357284526

# Copy dependencies
COPY --chown=tomcat lib/server/ /usr/local/tomcat/lib/
COPY --chown=tomcat lib/webapp/ /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# When deploying the "context.xml" should be copied to /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml
COPY --chown=tomcat context.xml /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml

# Copy Frank!
COPY --chown=tomcat classes/ /opt/frank/resources/

# Compile custom class, this should be changed to a buildstep in the future
COPY --chown=tomcat java /tmp/java
RUN javac \
      /tmp/java/nl/nn/adapterframework/http/HttpSenderBase.java \
      /tmp/java/nl/nn/adapterframework/http/Parameter.java \
      -classpath "/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
      -verbose -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes
RUN rm -rf /tmp/java

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=60 \
  CMD curl --fail --silent http://localhost:8080/iaf/api/server/health || (curl --silent http://localhost:8080/iaf/api/server/health && exit 1)
