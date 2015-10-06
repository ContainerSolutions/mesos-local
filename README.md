# mesos-local

When starting the container, ensure:

* the environment variable `NUMBER_OF_SLAVES` is set to an integer
  greater than 0, specifying the number of Mesos slaves to create

* For each slave *i* in `1`, `2`, .. `NUMBER_OF_SLAVES`, the
  environment variable `ENV_SLAVE`*i*`_RESOURCES` is set to a string
  to be passed as the `--resources` argument to that Mesos slave as
  described by [the documentation for Mesos
  configuration](http://mesos.apache.org/documentation/latest/configuration/).

* the environment variable `MESOS_CREDENTIALS_FILE_CONTENTS`, if set,
  is a string which can be used as the contents of a file passed as
  the `--credentials` argument to `mesos-master` as described in [the
  documentation for Mesos
  configuration](http://mesos.apache.org/documentation/latest/configuration/).

