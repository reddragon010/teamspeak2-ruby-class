require "ruby_ts2_class"
require "test/unit"

class TestRTS2Class < Test::Unit::TestCase
  def setup
    @ts2 = RubyTS2Class.new
    @ts2.connect("dreamblaze.net",8767)
  end
  
  def test_data
    assert_equal("2.0.24.1 Linux Freeware",@ts2.server_version)
    assert(@ts2.server_playerlist, "Can't reserve Playerlist")
  end
  
  def test_login
    assert(@ts2.login("test","test"),"Can't Login")
  end
  
  def test_disconnect
    assert_equal(true, @ts2.disconnect)
  end
  
end
