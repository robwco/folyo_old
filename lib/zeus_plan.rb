require 'zeus/rails'

class ZeusPlan < Zeus::Rails

  def boot
    require BOOT_PATH
    require "active_record"
    require "action_controller/railtie"
    require "action_mailer/railtie"
    require "active_resource/railtie"
    require "rails/test_unit/railtie"
    require "active_support/version"
  end

end

Zeus.plan = ZeusPlan.new
