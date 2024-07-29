# hiera_redis

## Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with hiera_redis](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hiera_redis](#beginning-with-hiera_redis)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module provides a Hiera 5 backend for Redis.

## Setup

### Setup Requirements

The backend requires the [redis](https://github.com/redis/redis-rb) gem installed in the Puppet Server JRuby.
It can be installed with:

```bash
/opt/puppetlabs/bin/puppetserver gem install redis
```

It is also recommended to install the gem into the agent's Ruby:

```bash
/opt/puppetlabs/puppet/bin/gem install redis
```

This allows commands such as `puppet apply` or `puppet lookup` to use the backend.

### Beginning with hiera_redis

If Redis is running on the Puppet master with the default settings, specifying the `lookup_key` as 'redis_lookup_key' is sufficient, for example

```yaml
---
version: 5
hierarchy:
  - name: hiera_redis
    lookup_key: redis_lookup_key
```

## Usage

By default, the backend will query Redis with the key provided.
It is also possible to query multiple scopes such as with the YAML backend, where the expected key in Redis is composed of the scope and the key separated by a character (default is `:`). For example, the following can be used:

```yaml
---
version: 5
hierarchy:
  - name: hiera_redis
    lookup_key: redis_lookup_key
    options:
      confine_to_keys:
        - '^redis_.*'
        - '^myapp_.*'
        - '^ssh_group$'
      scopes:
        - "osfamily/%{facts.os.family}"
        - common
```

The backend then expects keys of a format such as `common:foo::bar` for a lookup of 'foo::bar'.

The other options available include:

* `host`: The host that Redis is located on. Defaults to 'localhost'.
* `port`: The port that Redis is running on. Defaults to 6379.
* `socket`: Optional Unix socket path
* `password`: Optional Redis password
* `db`: The database number to query on the Redis instance. Defaults to 0.
* `scope`: The scope to use when querying the database.
* `scopes`: An array of scopes to query. Cannot be used in conjunction with the `scope` option.
* `separator`: The character separator between the scope and key being queried. Defaults to ':'.
* `confine_to_keys`: Only use this backend if the key matches one of the regexes in the array:

```yaml
  confine_to_keys:
    - "application.*"
    - "apache::.*"
```

## Limitations

This module has only been tested on CentOS.

## Development

PRs welcome.
