require File.dirname(__FILE__)+'/test_helper'

class HasTimelineTest < Test::Unit::TestCase
  def test_should_have_many_timeline_events
    reflection = Person.reflect_on_association(:timeline_events)
    assert reflection
    assert_equal :has_many, reflection.macro
  end
end
