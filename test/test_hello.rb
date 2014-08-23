require 'turingbot/test_case'

class TestHelloCommand < Turingbot::TestCase
  def test_hello
    response = inject "hello there", 'user_name' => 'tester'
    assert_equal "back attacha' tester", response.body["text"]
  end
end
