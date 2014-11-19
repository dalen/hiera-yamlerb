This is a YAML+ERB backend for hiera. It works like the regular YAML backend
but allows you to also template the YAML file using ERB syntax on the entire
fact scope.

This can be used to prevent a sprawl of hiera hierarchy levels that are only
used once or twice. Can also be used to reduce data duplication where several
different fact values should evaluate to the same value.

However you might not want to put too much code back into your data once you
have actually separated your data and code, but up to you :)

Examples:
=========

Match on two different fact values instead of repeating that value in two
different YAML files:

```
<% if ["Linux", "Darwin"].include? @kernel -%>
puppet::version: '3.7.3'
<% else -%>
puppet::version: '3.7.2'
<% end %>
```

Use a hiera value for a range of fact values

```
<% if @processorcount.between?(4,8) -%>
apache::max_keepalive_requests: 200
<% end -%>
```

Calculate a value for a hiera key:

```
puppetdb::max_treads: <%= [@processorcount - 1,1].max %>
```
