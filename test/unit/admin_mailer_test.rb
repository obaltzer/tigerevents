require File.dirname(__FILE__) + '/../test_helper'
require 'admin_mailer'

class AdminMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_group_approved,
    @expected.subject = encode 'AdminMailer#group_approved,'
    @expected.body    = read_fixture('group_approved,')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AdminMailer.create_group_approved,(@expected.date).encoded
  end

  def test_accepted,
    @expected.subject = encode 'AdminMailer#accepted,'
    @expected.body    = read_fixture('accepted,')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AdminMailer.create_accepted,(@expected.date).encoded
  end

  def test_account_created
    @expected.subject = encode 'AdminMailer#account_created'
    @expected.body    = read_fixture('account_created')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AdminMailer.create_account_created(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/admin_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
