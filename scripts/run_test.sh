#!/bin/bash -exv

# Identify the bin dir in the distribution, and source the common include script
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
cd $BASE_DIR

export JVM_OPTS="-XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:ReservedCodeCacheSize=96m -XX:+TieredCompilation -XX:MaxPermSize=256m -Xms256m -Xmx512m -Xss2m"


INNER_JAVA_OPTS="set javaOptions += \"-Dlog4j.configuration=file://$TRAVIS_BUILD_DIR/project/travis-log4j.properties\""

withCmd() {
  CMD=$1
  for t in $TEST_TARGET; do echo -n "; $t/$CMD "; done
}

bash -c "while true; do echo -n .; sleep 5; done" &

echo "running..."

echo time ./sbt -Dhttp.keepAlive=false -Dsbt.repository.secure=true ++$TRAVIS_SCALA_VERSION "$(withCmd "test:compile")"
export JVM_OPTS="-XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:ReservedCodeCacheSize=168m -XX:+TieredCompilation -XX:MaxPermSize=256m -Xms512m -Xmx1500m -Xss8m"

time ./sbt -Dhttp.keepAlive=false -Dsbt.repository.secure=true ++$TRAVIS_SCALA_VERSION "$(withCmd "test:compile")"

export JVM_OPTS="-XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:ReservedCodeCacheSize=128m -XX:+TieredCompilation -XX:MaxPermSize=256m -Xms256m -Xmx768m -Xss2m"
echo "calling ... "
echo "time ./sbt ++$TRAVIS_SCALA_VERSION $(withCmd test)"
time ./sbt -Dhttp.keepAlive=false -Dsbt.repository.secure=true  ++$TRAVIS_SCALA_VERSION "$(withCmd test)"
TST_EXIT_CODE=$?

echo "Running mima checks ... "
echo "time ./sbt ++$TRAVIS_SCALA_VERSION $(withCmd mimaReportBinaryIssues)"
time ./sbt -Dhttp.keepAlive=false -Dsbt.repository.secure=true  ++$TRAVIS_SCALA_VERSION "$(withCmd mimaReportBinaryIssues)"
MIMA_EXIT_CODE=$?

echo "Running compile:doc ... "
echo "time ./sbt ++$TRAVIS_SCALA_VERSION $(withCmd compile:doc)"
time ./sbt -Dhttp.keepAlive=false -Dsbt.repository.secure=true  ++$TRAVIS_SCALA_VERSION "$(withCmd compile:doc)"
COMPILE_DOC_EXIT_CODE=$?

echo "all done"

exit $(( $TST_EXIT_CODE || $MIMA_EXIT_CODE || $COMPILE_DOC_EXIT_CODE ))
