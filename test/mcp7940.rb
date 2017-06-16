# PlatoDevice::MCP7940 class

class I
  attr_accessor :indata
  attr_reader :outdata
  def initialize(addr)
    @addr = addr
    @indata = []
    @outdata = []
  end
  def read(reg, len, type=:as_array)
    d = []
    len.times {d << @indata.shift}
    return d if type == :as_array
    s = ''
    d.each {|b| s << b.chr}
    s
  end
  def write(reg, data)
    @outdata << data
  end
end
module PlatoDevice
  class MCP7940
    attr_reader :i2c
  end
end

assert('MCP7940', 'class') do
  assert_equal(PlatoDevice::MCP7940.class, Class)
end

assert('MCP7940', 'superclass') do
  assert_equal(PlatoDevice::MCP7940.superclass, Plato::RTC)
end

assert('MCP7940', 'new') do
  assert_nothing_raised {
    Plato::I2C.register_device(I)
    PlatoDevice::MCP7940.new(0)
  }
end

assert('MCP7940', 'get_time') do
  Plato::I2C.register_device(I)
  rtc = PlatoDevice::MCP7940.instance(0)
  rtc.i2c.indata = [0x17,4,5,6,7,8, 0x17,0x12,0x31,0x23,0x59,0x59]   # 2017/04/05 06:07:08, 2017/12/31 23:59:59
  assert_equal(rtc.get_time, [2017, 4, 5, 6, 7, 8])
  assert_equal(PlatoDevice::MCP7940.get_time, [2017, 12, 31, 23, 59, 59])
end

assert('MCP7940', 'set_time') do
  Plato::I2C.register_device(I)
  rtc = PlatoDevice::MCP7940.instance(0)
  rtc.set_time('20170102030405')
  assert_equal(rtc.i2c.outdata, [0, 0x17, 1, 2, 0x08, 3, 4, 0x85])
  rtc.i2c.outdata.clear
  rtc.set_time([2016, 12, 31, 23, 59, 59])
  assert_equal(rtc.i2c.outdata, [0, 0x16, 0x12|0x20, 0x31, 0x08, 0x23, 0x59, 0x59|0x80])
  rtc.i2c.outdata.clear
  PlatoDevice::MCP7940.set_time([2017, 4, 6, 8])
  assert_equal(rtc.i2c.outdata, [0, 0x17, 0x04, 0x06, 0x08, 0x08, 0x00, 0x80])
end
