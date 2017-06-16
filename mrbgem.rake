MRuby::Gem::Specification.new('mruby-plato-rtc-mcp7940') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Plato developers'
  spec.description = 'PlatoDevice::MCP7940 class (MCP7940 - I2C serial real time clock)'

  spec.add_dependency('mruby-plato-i2c')
  spec.add_dependency('mruby-plato-rtc')
  spec.add_test_dependency('mruby-string-ext')
end
