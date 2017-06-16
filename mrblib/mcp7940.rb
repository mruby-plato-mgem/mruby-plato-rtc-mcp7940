#
# PlatoDevice::MCP7940 class
#
module PlatoDevice
  class MCP7940 < Plato::RTC
    I2CADDR = 0x6f
    BASEYEAR = 2000

    # REGISTERS
    RTCSEC      = 0x00  # TIMEKEEPING SECONDS VALUE REGISTER (ADDRESS 0x00)
    RTCMIN      = 0x01  # TIMEKEEPING MINUTES VALUE REGISTER (ADDRESS 0x01)
    RTCHOUR     = 0x02  # TIMEKEEPING HOURS VALUE REGISTER (ADDRESS 0x02)
    RTCWKDAY    = 0x03  # TIMEKEEPING WEEKDAY VALUE REGISTER (ADDRESS 0x03)
    RTCDATE     = 0x04  # TIMEKEEPING DATE VALUE REGISTER (ADDRESS 0x04)
    RTCMTH      = 0x05  # TIMEKEEPING MONTH VALUE REGISTER (ADDRESS 0x05)
    RTCYEAR     = 0x06  # TIMEKEEPING YEAR VALUE REGISTER (ADDRESS 0x06)

    R00_ST      = 0x80  # [RW] Start Oscillator bit      0:disable, 1:enable
    R02_12HOUR  = 0x40  # [RW] 12-hour format            0:24hour, 1:12hour 
    R02_AMPM    = 0x20  # [RW] AM/PM (12-hour mode)      0:AM, 1:PM
    R03_OSCRUN  = 0x20  # [RO] Oscillator Status bit     0:disable, 1:enable
    R03_PWRFAIL = 0x10  # [RW] Power Failure Status bit  0:not lost, 1:lost
    R03_VBATEN  = 0x08  # [RW] Battery Supply Enable     0:disable, 1:enable
    R05_LPYR    = 0x20  # [RW] Leap Year bit             0:not leap year, 1:leap year

    def initialize(addr=I2CADDR)
      @i2c = Plato::I2C.open(addr)
    end

    def self.instance(addr=I2CADDR)
      @@rtc = self.new(addr) unless @@rtc
      @@rtc
    end

    def set_time(time)
      tm = []
      case time
      when Array  # [year, month, day, hour, minute, second]
        tm = time.clone
        tm[0] %= 100
      when String # 'yyyyMMddhhmmss'
        (time.size / 2).to_i.times {|i|
          tm << time[i*2, 2].to_i
        }
        tm.shift  # discard century
      end
      raise ArgumentError.new("Illegal time format (#{time})") unless tm.instance_of?(Array) && tm.size >= 3
      (6 - tm.size).times {tm << 0}
      leap_year = ((tm[0] % 4) == 0) ? R05_LPYR : 0 # TODO
      weekday = R03_VBATEN # TODO

      # RTC stop
      @i2c.write(RTCSEC, 0)

      # set time
      @i2c.write(RTCYEAR, tm[0].to_s.to_i(16))              # year
      @i2c.write(RTCMTH,  tm[1].to_s.to_i(16) | leap_year)  # month
      @i2c.write(RTCDATE, tm[2].to_s.to_i(16))              # day
      @i2c.write(RTCWKDAY,weekday)                          # weekday
      @i2c.write(RTCHOUR, tm[3].to_s.to_i(16))              # hour (24-hour)
      @i2c.write(RTCMIN,  tm[4].to_s.to_i(16))              # minute
      @i2c.write(RTCSEC,  tm[5].to_s.to_i(16) | R00_ST)     # second, start
    end

    def get_time
      tm = []
      raw = [RTCYEAR, RTCMTH, RTCDATE, RTCHOUR, RTCMIN, RTCSEC].map {|reg|
        @i2c.read(reg, 1)[0]
      }
      tm[0] = raw[0].to_s(16).to_i + BASEYEAR
      tm[1] = (raw[1] & ~R05_LPYR).to_s(16).to_i
      tm[2] = raw[2].to_s(16).to_i
      tm[3] = raw[3].to_s(16).to_i
      tm[4] = raw[4].to_s(16).to_i
      tm[5] = (raw[5] & ~R00_ST).to_s(16).to_i
      tm
    end

    def self.set_time(time)
      self.instance.set_time(time)
    end

    def self.get_time
      self.instance.get_time
    end
  end
end
