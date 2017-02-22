class GameNotification
  def self.publish(resource)
    uri = URI.parse('http://ortc-developers-useast1-s0001.realtime.co')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new('/send')
    req.body = {
      'AK' => Rails.application.secrets.pubnub_publish,
      'PK' => Rails.application.secrets.realtime_private,
      'C' => Rails.application.secrets.pubnub_channel,
      'M' => ActiveModel::SerializableResource.new(resource).serializable_hash.to_json
    }.to_param
    http.request(req)
  end
end
