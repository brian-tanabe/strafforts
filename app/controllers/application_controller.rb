require 'creators/activity_creator'
require 'creators/athlete_creator'
require 'creators/gear_creator'
require 'creators/location_creator'
require 'creators/heart_rate_zones_creator'
require 'activity_fetcher'
require 'mailchimp_api_wrapper'
require 'strava_api_wrapper'

class ApplicationController < ActionController::Base
  STRAVA_API_AUTH_AUTHORIZE_URL = Settings.strava.api_auth_authorize_url
  STRAVA_API_AUTH_TOKEN_URL = Settings.strava.api_auth_token_url
  STRAVA_API_AUTH_DEAUTHORIZE_URL = Settings.strava.api_auth_deauthorize_url
  STRAVA_API_CLIENT_ID = Settings.strava.api_client_id
  STRAVA_ATHLETES_URL = Settings.strava.athletes_base_url

  protect_from_forgery with: :exception

  def self.get_auth_url(request)
    "#{STRAVA_API_AUTH_AUTHORIZE_URL}"\
    "?client_id=#{STRAVA_API_CLIENT_ID}"\
    '&response_type=code'\
    "&redirect_uri=#{request.protocol}#{request.host}:#{request.port}/auth/exchange_token"\
    '&approval_prompt=auto&scope=view_private'
  end

  def self.get_meta(athlete_id, items, item_type) # rubocop:disable CyclomaticComplexity, MethodLength
    results = []

    items.each do |item| # rubocop:disable BlockLength
      case item_type
      when ApplicationHelper::ViewType::BEST_EFFORTS
        model = BestEffortType.find_by_name(item[:name])
        next if model.nil?

        best_efforts = BestEffort.find_all_by_athlete_id_and_best_effort_type_id(athlete_id, model.id)
        result = {
          name: item[:name],
          count: best_efforts.nil? ? 0 : best_efforts.size,
          is_major: item[:is_major]
        }
      when ApplicationHelper::ViewType::RACES_BY_DISTANCE
        model = RaceDistance.find_by_name(item[:name])
        next if model.nil?

        races = Race.find_all_by_athlete_id_and_race_distance_id(athlete_id, model.id)
        result = {
          name: item[:name],
          count: races.nil? ? 0 : races.size,
          is_major: item[:is_major]
        }
      when ApplicationHelper::ViewType::RACES_BY_YEAR
        result = {
          name: item[0].to_i.to_s,
          count: item[1],
          is_major: true
        }
      else
        next
      end

      results << result
    end
    results
  end

  def self.raise_athlete_not_found_error(id_or_username)
    error_message = "Could not find athlete '#{id_or_username}' by id or username."
    raise ActionController::RoutingError, error_message
  end

  def self.raise_athlete_not_accessible_error(id_or_username)
    error_message = "Could not access athlete '#{id_or_username}'."
    raise ActionController::RoutingError, error_message
  end

  def self.raise_item_not_found_error(item_type, item_name)
    error_message = "Could not find requested #{item_type} '#{item_name}'."
    raise ActionController::BadRequest, error_message
  end

  def self.raise_user_not_current_error
    error_message = 'Could not update a user that is not the current user.'
    raise ActionController::BadRequest, error_message
  end
end
