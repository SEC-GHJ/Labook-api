# frozen_string_literal: true

require 'uri'
require 'net/http'

module Labook
  # Service object to send line notification for receiver
  class SendNotificationToReceiver
    # if the line notify have something worng
    class LineNotifyError < StandardError
      def message
        'There is something wrong about the line notify.'
      end
    end

    def self.call(receiver:)
      return if receiver.line_notify_access_token.nil?

      uri = URI('https://notify-api.line.me/api/notify')
      header = { 'Authorization' => "Bearer #{receiver.line_notify_access_token}",
                 'Content-Type' => 'application/x-www-form-urlencoded' }
      data = {
        message: "\n有人在 Labook 上傳訊息給你! 要記得查看唷～\n\nSomeone sent you a message!! Please come back and see it."
      }
      data = URI.encode_www_form(data)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true # secure sockets layer, protect sensitive data from modification

      response = https.post(uri, data, header)

      JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
    end
  end
end
