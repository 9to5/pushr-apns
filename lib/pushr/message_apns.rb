module Pushr
  class MessageApns < Pushr::Message
    POSTFIX = 'apns'

    attr_accessor :type, :app, :device, :alert, :badge, :sound, :expiry, :attributes_for_device

    validates :badge, numericality: true, allow_nil: true
    validates :expiry, numericality: true, presence: true
    validates :device, format: { with: /\A[a-z0-9]{64}\z/ }
    validates_with Pushr::Apns::BinaryNotificationValidator

    def alert=(alert)
      if alert.is_a?(Hash)
        alert = MultiJson.dump(alert)
      else
        @alert = alert
      end
    end

    def alert
      string_or_json = @alert
      MultiJson.load(string_or_json) rescue string_or_json
    end

    # This method conforms to the enhanced binary format.
    # http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingWIthAPS/CommunicatingWIthAPS.html#//apple_ref/doc/uid/TP40008194-CH101-SW4
    def to_message
      [1, 0, expiry, 0, 32, device, payload_size, payload].pack('cNNccH*na*')
    end

    def payload
      MultiJson.dump(as_json)
    end

    def payload_size
      payload.bytesize
    end

    def to_json
      hsh = { type: self.class.to_s, app: app, device: device, alert: alert, badge: badge,
              sound: sound, expiry: expiry, attributes_for_device: attributes_for_device }
      MultiJson.dump(hsh)
    end

    private

    def as_json
      json = ActiveSupport::OrderedHash.new
      json['aps'] = ActiveSupport::OrderedHash.new
      json['aps']['alert'] = alert if alert
      json['aps']['badge'] = badge if badge
      json['aps']['sound'] = sound if sound
      attributes_for_device.each { |k, v| json[k.to_s] = v.to_s } if attributes_for_device
      json
    end
  end
end
