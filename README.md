# <a name="title"></a> chef-logstash [![Build Status](https://secure.travis-ci.org/lusis/chef-logstash.png?branch=master)](http://travis-ci.org/lusis/chef-logstash)

Description
===========

This is the semi-official 'all-in-one' Logstash cookbook.

This cookbook is primarily a library cookbook.

While you can still use the `agent` and `server` recipes, they are not recommended as they are very limited in what they do.

If you are using logstash < 1.2 you might want to use the 0.6.x branch.
If you are using logstash < 1.4 you might want to use the 0.7.x branch.

Requirements
============

All of the requirements are explicitly defined in the recipes. Every
effort has been made to utilize Community Cookbooks.

However if you wish to use an external ElasticSearch cluster, you will
need to install that yourself and change the relevant attributes for
discovery. The same applies to integration with Graphite.

This cookbook has been tested together with the following cookbooks,
see the Berksfile for more details

* [Heavywater Graphite Cookbook](https://github.com/hw-cookbooks/graphite)   - This is the one I use
* [Karmi's ElasticSearch Cookbook](https://github.com/elasticsearch/cookbook-elasticsearch)
* [@lusis Kibana cookbook](https://github.com/lusis/chef-kibana)
* [Community Beaver cookbook](https://supermarket.getchef.com/cookbooks/beaver)
* [elkstack community cookbook](https://supermarket.getchef.com/cookbooks/elkstack)

Attributes
==========

## Default

see [attributes/default.rb](attributes/default.rb)

## Beaver (alternative to Logstash Agent)

no longer used.  see [Community Beaver cookbook](https://supermarket.getchef.com/cookbooks/beaver)

## Source

no longer supports installing from source.

Lightweight Resource Providers
===================

These now do all the heavy lifting.

## logstash_instance

This will install a logstash instance.   It will take defaults from attributes for most attributes.

see [resources/instance.rb](resources/instance.rb)

## logstash_service

This will create system init scripts for managing logstash instance.   It will take defaults from attributes for most attributes.

see [resources/service.rb](resources/service.rb)

_experimental support for pleaserun has been added.   Only `native` for `Ubuntu 12.04` has been thoroughly tested._

## logstash_config

This will create logstash config files.   It will take defaults from attributes for most attributes.

see [resources/config.rb](resources/config.rb)

## logstash_pattern

This will install custom grok patterns for logstash.   It will take defaults from attributes for most attributes:

see [resources/pattern.rb](resources/pattern.rb)

## logstash_plugins

This will install the logstash community plugins:

see [resources/plugins.rb](resources/plugins.rb)

## logstash_curator

This will install the [ElasticSearch Curator](https://github.com/elasticsearch/curator) and setup a cron job. This replaces the deprecated `index_cleaner`:

see [resources/curator.rb](resources/curator.rb)

## attribute precidence in logstash LWRPs

We've done our best to make this intuitive and easy to use.

1. the value directly in the resource block.
2. the value from the hash node['logstash']['instance'][name]
3. the value from the hash node['logstash']['instance_default']

You should be able to override settings in any of the above places.  It is recommended for readability that you set non-default options in the LWRP resource block.  But do whichever makes sense to you.

Searching
======

There is a search helper library `libraries/search.rb` which will help you search for values such as `elasticsearch_ip`.  see the `server` recipe for an example of its usage.


Testing
=======

## Vagrant

__depreciated in favor if test kitchen.__

```
$ vagrant up precise64
```

## Rubocop, FoodCritic, Rspec, Test-Kitchen

```
$ bundle exec rake
```

## Test Kitchen

```
$ kitchen converge server_ubuntu
```

Contributing
========

Any and all contributions are welcome.   We do ask that you test your contributions with the testing framework before you send a PR.  All contributions should be made against the master branch.

Please update tests and changelist with your contributions.

Documentation contributions will earn you lots of hugs and kisses.

Usage
=====

A proper readme is forthcoming but in the interim....

These two recipes show how to install and configure logstash instances via the provided `LWRPs`

* [recipes/server.rb](recipes/server.rb) - This would be your indexer node
* [recipes/agent.rb](recipes/agent.rb) - This would be a local host's agent for collection

See the [elkstack community cookbook](https://supermarket.getchef.com/cookbooks/elkstack) for a great example of using the LWRPs provided by this cookbook.


# Vagrant

## Requirements
* Vagrant 1.2.1+
* Vagrant Berkshelf Plugin `vagrant plugin install vagrant-berkshelf`
* Vagrant Omnibus Plugin   `vagrant plugin install vagrant-omnibus`

Uses the Box Name to determine the run list ( based on whether its Debian or RHEL based ).

See chef_json and chef_run_list variables to change recipe behavior.

## Usage:

Run Logstash on Ubuntu Lucid   : `vagrant up lucid32` or `vagrant up lucid64`

Run Logstash on Centos 6 32bit : `vagrant up centos6_32`

Logstash will listen for syslog messages on tcp/5140


## License and Author

- Author:    John E. Vincent
- Author:    Bryan W. Berry (<bryan.berry@gmail.com>)
- Author:    Richard Clamp (@richardc)
- Author:    Juanje Ojeda (@juanje)
- Author:    @benattar
- Author:    Paul Czarkowski (@pczarkowski)
- Copyright: 2012, John E. Vincent
- Copyright: 2012, Bryan W. Berry
- Copyright: 2012, Richard Clamp
- Copyright: 2012, Juanje Ojeda
- Copyright: 2012, @benattar
- Copyright: 2014, Paul Czarkowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
