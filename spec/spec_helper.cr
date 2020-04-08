require "json"
require "spec"
require "webmock"
require "../src/office365"

module SpecHelper
  extend self

  def mock_client_auth
    WebMock.stub(:post, "https://login.microsoftonline.com/#{mock_credentials[:tenant]}/oauth2/v2.0/token")
      .to_return(mock_token.to_json)
  end

  def mock_token
    Office365::Token.new(
      access_token: "access_token",
      token_type: "token_type",
      expires_in: 12345)
  end

  def mock_user
    Office365::User.from_json(%{{"id":"1234","mail":"foo@bar.com","displayName":"Foo Bar"}})
  end

  def mock_user_query
    Office365::UserQuery.new(value: [mock_user])
  end

  def mock_get_user
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/#{mock_user.id}")
      .to_return(mock_user.to_json)
  end

  def mock_list_users
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users?%24filter=accountEnabled+eq+true")
      .to_return(mock_user_query.to_json)
  end

  def mock_calendar
    Office365::Calendar.from_json(%{{"id":"1234","name":"Test calendar"}})
  end

  def mock_calendar_query
    Office365::CalendarQuery.new(value: [mock_calendar])
  end

  def mock_list_calendars
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/#{mock_user.mail}/calendars?")
      .to_return(mock_calendar_query.to_json)
  end

  def mock_list_calendar_groups
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendarGroups?%24top=99")
      .to_return(mock_calendar_group_query.to_json)
  end

  def mock_calendar_group
    Office365::CalendarGroup.from_json(%{{"id":"1234","name":"My Calendar Group"}})
  end

  def mock_calendar_group_query
    Office365::CalendarGroupQuery.new(value: [mock_calendar_group])
  end

  def mock_create_calendar
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendars")
      .to_return(mock_calendar.to_json)
  end

  def mock_create_calendar_group
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendarGroups")
      .to_return(mock_calendar_group.to_json)
  end

  def mock_delete_calendar
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendars/1234").to_return(body: "")
  end

  def mock_delete_calendar_group
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendarGroups/1234").to_return(body: "")
  end

  def mock_event_data
    {
      starts_at: Time.local,
      ends_at:   Time.local + 30.minutes,
      subject:   "My Unique Event Subject",
      rooms:     ["Red Room"],
      attendees: ["elon@musk.com", Office365::EmailAddress.new(address: "david@bowie.net", name: "David Bowie"), Office365::Attendee.new(email: "the@goodies.org")],
    }
  end

  def mock_event
    Office365::Event.new(**mock_event_data)
  end

  def mock_event_query
    Office365::EventQuery.new(value: [mock_event])
  end

  def mock_list_events
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events?%24top=10").to_return(mock_event_query.to_json)
  end

  def mock_create_event
    WebMock.stub(:post, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events").to_return(mock_event.to_json)
  end

  def mock_get_event
    WebMock.stub(:get, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234").to_return(mock_event.to_json)
  end

  def mock_update_event
    WebMock.stub(:patch, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/").to_return(Office365::Event.new(**mock_event_data.merge(subject: "A Whole New Name!")).to_json)
  end

  def mock_delete_event
    WebMock.stub(:delete, "https://graph.microsoft.com/v1.0/users/foo@bar.com/calendar/events/1234").to_return(body: "")
  end

  def mock_credentials
    {tenant: "tentant", client_id: "client_id", client_secret: "client_secret"}
  end
end

Spec.before_each do
  WebMock.reset
end