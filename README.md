# mruby-plato-rtc-mcp7940   [![Build Status](https://travis-ci.org/mruby-plato/mruby-plato-rtc-mcp7940.svg?branch=master)](https://travis-ci.org/mruby-plato/mruby-plato-rtc-mcp7940)
PlatoDevice::MCP7940 class (MCP7940 - I2C serial real time clock)
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

  # ... (snip) ...

  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-i2c'
  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-rtc'
  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-rtc-mcp7940'
end
```

## example
```ruby
puts PlatoDevice::MCP7940.get_time
```

## License
under the MIT License:
- see LICENSE file
