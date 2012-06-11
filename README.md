Description
===========
This is the semi-official 'all-in-one' Logstash cookbook.

Requirements
============

Attributes
==========

Usage
=====
A proper readme is forthcoming but in the interim....

There are 3 recipes you need to concern yourself with:

* server - This would be your indexer node
* agent - This would be a local host's agent for collection
* kibana - This is the web interface

Every attempt (and I mean this) was made to ensure that the following objectives were met:

* Any agent install can talk to a server install
* Kibana web interface can talk to the server install
* Each component works OOB and with each other
* Utilize official opscode cookbooks where possible

This setup makes HEAVY use of roles. Additionally, ALL paths have been made into attributes. Everything I could think of that would need to be customized has been made an attribute.

## Defaults
By default, the recipes look for the following roles (defined as attributes so they can be overridden):

* `graphite_server` - `node[:logstash][:graphite_role]`
* `elasticsearch_server` - `node[:logstash][:elasticsearch_role]`
* `logstash_server` - `node[:logstash][:kibana][:elasticsearch_role]` and `node[:logstash][:agent[:server_role]`

The reason for giving `kibana` its own role assignment is to allow you to point to existing ES clusters/logstash installs.

The reason for giving `agent` its own role assignment is to allow the `server` and `agent` recipes to work together.

## Agent and Server configuration
The template to use for configuration is made an attribute as well. This allows you to define your OWN logstash configuration file without mucking with the default templates.

The `server` will, by default, enable the embedded ES server. This can be overriden as well.

See the `server` and `agent` attributes for more details.

## Source vs. Jar install methods
Both `agent` and `server` support an attribute for how to install. By default this is set to `source` since the logtash chef handler requires changes only present in master. The current release is defined in attributes if you choose to go the `jar` route.

## Out of the box behaviour
Here are some basic steps

* Create a role called `logstash_server` and assign it the following recipes: `logstash::server` and `logstash::kibana`
* Assign the role to a new server
* Assign the `logstash::agent` recipe to another server

If there is a system found with the `logstash_server` role, the agent will automatically configure itself to send logs to it over tcp port 5959. This is, not coincidently, the port used by the chef logstash handler.

If there is NOT a system with the `logstash_server` role, the agent will use a null output. The default input is to read files from `/var/log/*.log` excluding and gzipped files.

If you point your browser to the `logstash_server` system's ip address, you should get the kibana web interface.

Do something to generate a new line in any of the files in the agent's watch path (I like to SSH to the host), and the events will start showing up in kibana. You might have to issue a fresh empty search.

The `pyshipper` recipe will work as well but it is NOT wired up to anything yet.

# BIG WARNING

* Everything uses `runit`. Get over it. I'll take patches but I'm not fucking with init scripts myself.
* Currently only tested on Ubuntu Natty. However everything **NOT** logstash-y, is using official opscode cookbooks so if THOSE are cross platform, this should work. I do plan on testing myself.

# LICENSE
Apache 2.0, broheim.
