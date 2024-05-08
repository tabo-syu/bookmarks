require 'discordrb'

token = Rails.application.credentials.dig(:discord, :token)
Bot = Discordrb::Bot.new token: token
Bot.run(background: true)
