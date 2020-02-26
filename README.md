# We no longer use or update this cookbook

It has been adopted by these lovely people, and you should use their fork instead: https://github.com/sous-chefs/sc-nxlog

# NXLog Chef Cookbook 

[![Build Status](https://secure.travis-ci.org/widgit-cookbooks/nxlog.svg?branch=master)](https://travis-ci.org/widgit-cookbooks/nxlog)
[![Dependency Status](https://gemnasium.com/widgit-cookbooks/nxlog.svg)](https://gemnasium.com/widgit-cookbooks/nxlog)

**This documentation uses Github markdown and looks best on [the Github project page](http://github.com/widgit-cookbooks/nxlog)**

## About this cookbook

This cookbook sets up NXLog on a Windows or Linux host.

NXLog is a flexible log-management service that is able to read and write
logs in a variety of formats, and to numerous places.

This is a good solution if you want to gather the logs from various systems
or processes into a central location such as a syslog daemon or papertrail.
It can be used to merge log files, the kernel, syslog or the Windows event log
all into one place. It has powerful routing and conversion capabilities so that
logs can be written into different formats and sent to multiple places.

The cookbook provides LWRPs for log sources and destinations, and makes it easy
to set up routes between them.

The nxlog::syslog recipe sets up nxlog as the default system logger on Linux.

Additionally, this cookbook includes a Papertrail LWRP to simplify the
publishing of logs to that service. [Papertrail](https://papertrailapp.com/?thank=d131bd) is a web-based log aggregation
service that can receive logs from multiple servers and display them all in once place.

You may also create nxlog resources via node attributes, which saves you from
having to write a recipe for each one. This cookbook uses the `zap` cookbook
to ensure that resources configs are automatically removed from nodes when they
are removed from node attributes.

It is worth reading the [nxlog documentation](http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928) 
to get a better idea of how this stuff works.

## Supported Platforms

 * Windows Server 2008r2-2012r2
 * Ubuntu/Debian Linux
 * RHEL/Centos Linux

This cookbook requires Chef 12

## Usage

Include `nxlog` in your node's `run_list`:

```
{
    "run_list": [
        "recipe[nxlog::default]"
    ]
}
```

If you wish to enable Papertrail support, also include the papertrail recipe:

```
{
    "run_list": [
         "recipe[nxlog::default]"
         "recipe[nxlog::papertrail]"
    ]
}
```

To set up nxlog as the sytem logger you should include the syslog recipe:

```
{
    "run_list": [
         "recipe[nxlog::default]"
         "recipe[nxlog::syslog]"
    ]
}
```

The syslog recipe will disable rsyslog. If you are expecting another logging 
daemon you should specify this in node attributes. The default behaviour is
to send its log output to the default destinations, but this can be reconfigured
in node attributes.

This should be enough to get nxlog installed and running. However, it won't do
much on its own. In order for it to do something useful you need to configure
log sources and destinations.

A simple example recipe to log Windows events to a file:

```ruby
include_recipe 'nxlog::default'

nxlog_destination 'windows_events_file' do
  file 'c:/windows/temp/events.log'
end

nxlog_source 'event_log' do
  input_module 'im_msvistalog'
  destination 'windows_events_file'
end
```

This can also be accomplished using node attributes as follows:
```
{
  "nxlog": {
    "destinations": {
      "windows_events_file": {
        "file": "c:/windows/temp/events.log"
      }
    },
    "sources": {
      "event_log": {
        "input_module": "im_msvistalog",
        "destination": "windows_events_file"
      }
    }
  }
}
```

A more advanced recipe to log multiple sources to papertrail might look like:

```ruby
include_recipe 'nxlog::default'
include_recipe 'nxlog::papertrail'

nxlog_papertrail 'papertrail' do
  default true   # use this as the default destination for all inputs
  host 'logs2'
  port 11111
end

nxlog_source 'apache_errors' do
  file '/var/log/apache2/errors.log'
end

nxlog_source 'apache_access' do
  file '/var/log/apache2/access.log'
end
```

Again, this can be accomplished using node attributes:

```
{
  "nxlog": {
    "papertrails": {
      "papertrail": {
        "default": true,
        "host": "logs2",
        "port": 11111
      }
    },
    "sources": {
      "apache_errors": {
        "file": "/var/log/apache2/errors.log"
      },
      "apache_access": {
        "file": "/var/log/apache2/access.log"
      }
    }
  }
}
```

## Resources

The following describes each LWRP provided by this cookbook.

It is also possible to create the resources using node attributes as described
above. To do so, create them as hashes within:
```node['nxlog']['sources']```
```node['nxlog']['destinations']```
or
```node['nxlog']['papertrails']```

The name attribute should be the hash key for the object, and all attributes 
supported by the relevant LWRP are supported as name/value pairs inside the
object. See above for examples.

### nxlog_source

`nxlog_source` defines a source of log data which will be sent to one or more 
the defined log destinations.

NXLog has many different input modules that enable log data to be read from
a variety of log sources. The default is to read from a file, but any supported
module can be selected using the `input_module` attribute.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#modules_input

#### Syntax

**ruby**:

```ruby
nxlog_source "name" do
  attribute "value" # see attributes section below
  ...
  action :action
end
```

* `name` is a unique name for the log resource
* `attributes` define how the log source should be configured
* `action` should be either :create, or :delete *\[default: :create\]*

**json**:

```
{
  "nxlog": {
    "sources": {
      "<name>": {
        "<attribute>": "<value>"
      }
    }
  }
}
```

* `name` is a unique name for the log resource
* `attributes` define how the log source should be configured
* `action` is always :create and should not be specified

#### nxlog_source attributes

##### Attributes common to all modules

| Attribute name | Description                          | Type            | Default    |
| -------------- | ------------------------------------ | --------------- | ---------  |
| input_module   | input module to use for the log data | String          | 'im_file'  |
| destination    | destination(s) to send the data to   | String or Array | 'defaults' |
| input_type     | nxlog InputType (see nxlog docs)     | String          | none       |
| exec           | commands to execute on the log data  | String          | none       |
| flow_control   | enables or disables flow control     | Boolean         | false      |

**Notes:**

* input_module must be one of the modules defined below
* to send log data to specific log destinations in addition to the defaults, 
  include `'defaults'` in the destination array. For example:
```ruby
  destination ['my_special_destination', 'defaults']
```
* it is worth reading the documentation on `Exec` in the nxlog docs. Quite often
  log data needs to be transformed by a method such as `to_syslog_ietf()`

##### 'im_file' module

'im_file' defines a file-based log source

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_file

| Attribute name     | Description                                                      | Type    | Default              |
| ------------------ | ---------------------------------------------------------------- | ------- | -------------------  |
| file               | The file to read log data from                                   | String  | none - **Required**  |
| recursive          | Whether to recurse into subdirectories                           | boolean | false                |
| rename_check       | Check whether files are renamed (e.g. logrotate)                 | boolean | false                |
| close_when_idle    | Whether to close the file when not being read                    | boolean | false                |
| poll_interval      | How often to check for new data                                  | float   | 1.0                  |
| dir_check_interval | How often to check for new files when `file` contains a wildcard | float   | 2 * `poll_interval`  |
| active_files       | Maximum number of files to monitor simultaneously                | integer | 10                   |
| save_pos           | Whether to save the file position when nxlog exits               | boolean | true                 |

**Notes:**

* `recursive` works in a way that you might not expect. Read the nxlog docs if you plan to use it.

##### 'im_exec' module

'im_exec' executes a command and reads log data from stdout

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_exec

| Attribute name     | Description                                  | Type    | Default             |
| ------------------ | -------------------------------------------- | ------- | ------------------- |
| command            | The command to execute                       | String  | none - **Required** |
| args               | An array of arguments to pass to the command | Array   | none                |
| restart            | Whether to restart the command on exit       | boolean | false               |

##### 'im_internal' module

'im_internal' specifies nxlog's internal logs

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_internal

*There are no module-specific attributes for this module.*

##### 'im_kernel' module

'im_kernel' defines the kernel logs on Linux systems (e.g. `dmesg`)

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_kernel

*There are no module-specific attributes for this module.*

##### 'im_mark' module

'im_mark' periodically writes a specific string to the destination(s)

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_mark

| Attribute name | Description                                         | Type    | Default      |
| -------------- | --------------------------------------------------- | ------- | ------------ |
| mark           | The string to write to the logs                     | String  | '-- MARK --' |
| mark_interval  | How frequently to write the mark string, in minutes | integer | 30           |

##### 'im_mseventlog' module

'im_mseventlog' reads from the Windows XP (Server 2003) event log.

**NOTE:** For modern Windows (Vista and above) use 'im_msvistalog'

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_mseventlog

| Attribute name | Description                            | Type    | Default            |
| -------------- | ---------------------------------------| ------- | ------------------ |
| sources        | Which event log sources to use         | Array   | none (all sources) |
| utf8           | Whether to convert all strings to utf8 | boolean | true               |

##### 'im_msvistalog' module

'im_msvistalog' reads from the Windows (post-XP / Server 2003) event log.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_msvistalog

You may also want to read:

https://technet.microsoft.com/en-us/library/cc722404.aspx

| Attribute name | Description                                         | Type    | Default            |
| -------------- | --------------------------------------------------- | ------- | ------------------ |
| channel        | Which event log channel(s) to read from             | String  | none (all sources) |
| query          | Specifies the query to filter the results           | String  | none               |
| poll_interval  | How frequently the logs will be checked for changes | Float   | 1.0                |

##### 'im_null' module

'im_null' never generates any messages. However, commands
can be executed with the `exec` common attribute.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_null

*There are no module-specific attributes for this module.*

##### 'im_ssl' module

'im_ssl' messages are received from an SSL/TLS encrypted TCP connection.

Default behaviour is to listen on 'localhost', but you can use '0.0.0.0' to bind
to all addresses.

This module works identically to the im_tcp module, except that the connection
is encrypted.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_ssl

| Attribute name  | Description                                                      | Type    | Default             |
| ----------------| ---------------------------------------------------------------- | ------- | ------------------- |
| host            | The ip or hostname to listen on                                  | String  | 'localhost'         |
| port            | The tcp port to listen on                                        | Integer | none - **Required** |
| cert_file       | Path to the https certificate file                               | String  | none                |
| cert_key_file   | Path to the https certificate key file                           | String  | none                |
| key_pass        | Password for the certificate key file                            | String  | none                |
| ca_file         | Path to the certificate CA file                                  | String  | none                |
| ca_dir          | Path to a directory containing CA files                          | String  | none                |
| crl_file        | Path to a CRL file                                               | String  | none                |
| crl_dir         | Path to a directory containing CRL files                         | String  | none                |
| allow_untrusted | Whether https should be allowed without certificate verification | boolean | false               |

##### 'im_tcp' module

'im_tcp' messages are received from a TCP connection.

Default behaviour is to listen on 'localhost', but you can use '0.0.0.0' to bind
to all addresses.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_tcp

| Attribute name  | Description                                                      | Type    | Default             |
| ----------------| ---------------------------------------------------------------- | ------- | ------------------- |
| host            | The ip or hostname to listen on                                  | String  | 'localhost'         |
| port            | The tcp port to listen on                                        | Integer | none - **Required** |

##### 'im_udp' module

'im_udp' messages are received from a UDP connection.

Default behaviour is to listen on 'localhost', but you can use '0.0.0.0' to bind
to all addresses.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_udp

| Attribute name | Description                                                      | Type    | Default             |
| ---------------| ---------------------------------------------------------------- | ------- | ------------------- |
| host           | The host to listen on                                            | String  | 'localhost'         |
| port           | The udp port to connect to                                       | Integer | none - **Required** |
| sock_buf_size  | Sets the socket buffer size                                      | Integer | OS defaults         |

##### 'im_uds' module

'im_uds' messages are read from a unix domain socket, such as `/dev/log`. This module
will read from `/dev/log` if the *uds* attribute is not specified.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#im_uds

| Attribute name | Description                                                      | Type    | Default             |
| ---------------| ---------------------------------------------------------------- | ------- | ------------------  |
| uds            | The path of the unix domain socket.                              | String  | '/dev/log'          |

**Notes:**

* Only SOCK_DGRAM type sockets are currently supported by nxlog

### nxlog_destination

`nxlog_destination` defines a destination where log data from one or more
sources will be sent. 

NXLog has many different output modules that enable log data to be sent to
a variety of log sources. The default is to read from a file, but any supported
module can be selected using the `output_module` attribute.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#modules_output

#### Syntax

**ruby**:

```ruby
nxlog_destination "name" do
  attribute "value" # see attributes section below
  ...
  action :action
end
```

* `name` is a unique name for the destination resource
* `attributes` define how the log destination should be configured
* `action` should be either :create, or :delete *\[default: :create\]*

**json**:

```
{
  "nxlog": {
    "destinations": {
      "<name>": {
        "<attribute>": "<value>"
      }
    }
  }
}
```

* `name` is a unique name for the destination resource
* `attributes` define how the log destination should be configured
* `action` is always :create and should not be specified

#### nxlog_destination attributes

##### Attributes common to all modules

| Attribute name | Description                                      | Type            | Default   |
| -------------- | ------------------------------------------------ | --------------- | --------- |
| output_module  | input module to use for receiving the log data   | String          | 'om_file' |
| output_type    | nxlog OutputType (see nxlog docs)                | String          | none      |
| exec           | commands to execute on the log data              | String          | none      |
| default        | whether the destination is a default destination | boolean         | false     |


**Notes:**

* output_module must be one of the modules defined below
* it is worth reading the documentation on `Exec` in the nxlog docs. Quite often
  log data needs to be transformed by a method such as `to_syslog_ietf()`
* destinations marked as default will receive log data from all input sources,
  unless they specifically specify otherwise

##### 'om_file' module

'om_file' defines a file-based log destination

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_file

| Attribute name     | Description                                                         | Type    | Default              |
| ------------------ | ------------------------------------------------------------------- | ------- | -------------------- |
| file               | The file to write log data to                                       | String  | none - **Required**  |
| create_dir         | Whether to create a directory for the log file if it does not exist | boolean | false                |
| truncate           | Whether to truncate the log file before writing                     | boolean | false                |
| sync               | Whether to sync the log file after each message, flushing buffers   | boolean | false                |

##### 'om_blocker' module

'om_blocker' is a testing output module which simply blocks, simulation an blocked route.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_blocker

*There are no module-specific attributes for this module.*

##### 'om_dbi' module

'om_dbi' writes log data to a database

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_dbi

| Attribute name | Description                                                 | Type   | Default             |
| ---------------| ----------------------------------------------------------- | ------ | ------------------- |
| driver         | The dbi driver to use                                       | String | none - **Required** |
| sql            | The SQL to execute to insert the log data                   | String | none - **Required** |
| options        | Engine-specific options such as host, username and password | Array  | none - **Required** |

**Notes:**

* Requires libdbi the relevant libdbi driver to be installed
* See the nxlog docs for details on how to format SQL and options

##### 'om_exec' module

'om_exec' executes a command and pipes log data into it

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_exec

| Attribute name | Description                                  | Type   | Default             |
| ---------------| -------------------------------------------- | ------ | ------------------- |
| command        | The command to execute                       | String | none - **Required** |
| args           | An array of arguments to pass to the command | Array  | none                |

**Notes:**

* The command is executed when nxlog starts, and must not terminate until it shuts down

##### 'om_http' module

'om_http' posts log data to a specific url over http or https

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_http

| Attribute name        | Description                                                      | Type    | Default             |
| ----------------------| ---------------------------------------------------------------- | ------- | ------------------- |
| url                   | The url to post the data to                                      | String  | none - **Required** |
| content-type          | The content-type header of the http request                      | String  | 'text/plain'        |
| https_cert_file       | Path to the https certificate file                               | String  | none                |
| https_cert_key_file   | Path to the https certificate key file                           | String  | none                |
| https_key_pass        | Password for the certificate key file                            | String  | none                |
| https_ca_file         | Path to the certificate CA file                                  | String  | none                |
| https_ca_dir          | Path to a directory containing CA files                          | String  | none                |
| https_crl_file        | Path to a CRL file                                               | String  | none                |
| https_crl_dir         | Path to a directory containing CRL files                         | String  | none                |
| https_allow_untrusted | Whether https should be allowed without certificate verification | boolean | false               |

##### 'om_null' module

'om_null' messages are discarded and never written anywhere. However, commands
can be executed on the log data with the `exec` common attribute.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_null

*There are no module-specific attributes for this module.*

##### 'om_ssl' module

'om_ssl' messages are sent over an SSL/TLS encrypted TCP connection.

This module works identically to the om_tcp module, except that the connection
is encrypted.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_ssl

| Attribute name  | Description                                                      | Type    | Default             |
| ----------------| ---------------------------------------------------------------- | ------- | ------------------- |
| host            | The host to connect to                                           | String  | none - **Required** |
| port            | The tcp port to connect to                                       | Integer | none - **Required** |
| cert_file       | Path to the https certificate file                               | String  | none                |
| cert_key_file   | Path to the https certificate key file                           | String  | none                |
| key_pass        | Password for the certificate key file                            | String  | none                |
| ca_file         | Path to the certificate CA file                                  | String  | none                |
| ca_dir          | Path to a directory containing CA files                          | String  | none                |
| crl_file        | Path to a CRL file                                               | String  | none                |
| crl_dir         | Path to a directory containing CRL files                         | String  | none                |
| allow_untrusted | Whether https should be allowed without certificate verification | boolean | false               |

##### 'om_tcp' module

'om_tcp' messages are sent over a TCP connection.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_tcp

| Attribute name  | Description                                                      | Type    | Default             |
| ----------------| ---------------------------------------------------------------- | ------- | ------------------- |
| host            | The host to connect to                                           | String  | none - **Required** |
| port            | The tcp port to connect to                                       | Integer | none - **Required** |

##### 'om_udp' module

'om_udp' messages are sent over a UDP connection.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_udp

| Attribute name | Description                                                      | Type    | Default             |
| ---------------| ---------------------------------------------------------------- | ------- | ------------------- |
| host           | The host to connect to                                           | String  | none - **Required** |
| port           | The udp port to connect to                                       | Integer | none - **Required** |
| sock_buf_size  | Sets the socket buffer size                                      | Integer | OS defaults         |

##### 'om_uds' module

'om_uds' messages are written to a unix domain socket, such as `/dev/log`. This module
will write to `/dev/log` if the *uds* attribute is not specified.

http://nxlog.org/documentation/nxlog-community-edition-reference-manual-v20928#om_uds

| Attribute name | Description                                                      | Type    | Default             |
| ---------------| ---------------------------------------------------------------- | ------- | ------------------- |
| uds            | The path of the unix domain socket.                              | String  | '/dev/log'          |

### nxlog_papertrail

`nxlog_papertrail` defines a special kind of om_ssl destination that is pre-configured
to log to papertrail (https://papertrailapp.com/) and thus requiring only a few options
to set up.

#### Syntax

**ruby**:

```ruby
nxlog_papertrail "name" do
  attribute "value" # see attributes section below
  ...
  action :action
end
```

* `name` is a unique name for the papertrail resource
* `attributes` define how the papertrail log destination should be configured
* `action` should be either :create, or :delete *\[default: :create\]*

**json**:

```
{
  "nxlog": {
    "sources": {
      "<name>": {
        "<attribute>": "<value>"
      }
    }
  }
}
```

* `name` is a unique name for the papertrail resource
* `attributes` define how the papertrail log destination should be configured
* `action` is always :create and should not be specified

#### nxlog_papertrail attributes

| Attribute name | Description                                                       | Type    | Default             |
| ---------------| ----------------------------------------------------------------- | ------- | ------------------- |
| port           | The port for your papertrail log destination                      | String  | none - **Required** |
| host           | The \*.papertrailapp.com host to log to (e.g. 'logs', 'logs2')    | String  | 'logs'              |
| default        | Whether this is a default log destination (see nxlog_destination) | boolean | false               |

## Cookbook Attributes

The attributes mostly concern default config locations and will most likely work
for your platform without modification. 

| Key                             | Description                                           | Default                                                                        |
| ------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------- |
| version                         | The version of nxlog_ce to download and install       | '2.9.1347'                                                                      |
| log_level                       | nxlog's log level                                     | 'INFO'                                                                          |
| user                            | The unix user to run nxlog as (no effect on Windows)  | 'nxlog'                                                                         |
| group                           | The unix group to run nxlog as (no effect on Windows) | 'nxlog'                                                                         |
| conf_dir                        | The directory for the nxlog configuration files       | platform-specific                                                               |
| log_file                        | The location of the nxlog log file                    | platform-specific                                                               |
| checksums::\<package_filename\> | The sha256sum of the specified package                | nxlog version-specific                                                          |
| package_source                  | The base URL for downloading nxlog packages           | https://mirror.widgit.com/nxlog                                                 |
| papertrail::bundle_url          | The URL to the papertrail CA bundle                   | [papertrail-bundle.pem](https://papertrailapp.com/tools/papertrail-bundle.pem)  |
| syslog::logger_disable          | The logger service to disable in favour of nxlog      | 'rsyslog'                                                                       |
| syslog::destinations            | The destinations to log syslog data to                | 'defaults'                                                                      |
| sources                         | An array of log source objects                        | nil                                                                             |
| destinations                    | An array of log destination objects                   | nil                                                                             |
| papertrails                     | An array of papertrail log destination objects        | nil                                                                             |

## Contributing

You know the drill:

1. Fork
2. Branch
3. Change
4. Test
5. Pull request

## License and Authors

Author:: Simon Detheridge, Widgit Software (<simon@widgit.com>)

License:: Apache Version 2.0
