require 'turingbot/test_case'

class TestHelloCommand < Turingbot::TestCase
  def test_hello
    response = run_command "hello there", from: 'some-user'
    assert_equal "back attacha' some-user", response.body["text"]
  end
end
