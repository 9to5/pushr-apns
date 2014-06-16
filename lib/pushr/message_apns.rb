module Pushr
  class MessageApns < Pushr::Message
    POSTFIX = 'apns'

    attr_accessor :type, :app, :device, :badge, :sound, :expiry, :attributes_for_device, :content_available, :priority, :external_id

    validates :badge, numericality: true, allow_nil: true
    validates :expiry, numericality: true, presence: true
    validates :device, format: { with: /\A[a-z0-9]{64}\z/ }
    validates :priority, inclusion: { in: [5, 10] }
    validates :content_available, inclusion: { in: [1] }, allow_nil: true
    validate :max_payload_size
    validate :priority_with_content_available

    def alert=(alert)
      if alert.is_a?(Hash)
        @alert = MultiJson.dump(alert)
      else
        @alert = alert
      end
    end

    def alert
      string_or_json = @alert
      return MultiJson.load(string_or_json)
    rescue
      return string_or_json
    end

    def id
      @id ||= OpenSSL::Random.random_bytes(4)
    end

    def to_message
      data = ''
      data << [1, [device].pack('H*').bytesize, [device].pack('H*')].pack('CnA*')
      data << [2, payload.bytesize, payload].pack('CnA*')
      data << [3, id.bytesize, id].pack('CnA*')
      data << [4, 4, expiry].pack('CnN')
      data << [5, 1, priority].pack('CnC')
      ([2, data.bytesize].pack('CN') + data)
    end

    def payload
      MultiJson.dump(as_json)
    end

    def payload_size
      payload.bytesize
    end

    def to_json
      hsh = { type: self.class.to_s, app: app, device: device, alert: alert, badge: badge,
              sound: sound, expiry: expiry, attributes_for_device: attributes_for_device,
              content_available: content_available, priority: priority }
      hsh[Pushr::Core.external_id_tag] = external_id if external_id
      MultiJson.dump(hsh)
    end

    private

    def as_json
      json = ActiveSupport::OrderedHash.new
      json['aps'] = ActiveSupport::OrderedHash.new
      json['aps']['alert'] = alert if alert
      json['aps']['badge'] = badge if badge
      json['aps']['sound'] = sound if sound
      json['aps']['content-available'] = content_available if content_available
      attributes_for_device.each { |k, v| json[k.to_s] = v.to_s } if attributes_for_device
      json
    end

    def max_payload_size
      if payload_size > 256
        errors.add(:payload, 'APN notification cannot be larger than 256 bytes. Try condensing your alert and device attributes.')
      end
    end

    def priority_with_content_available
      if content_available == 1 && priority != 5 && !(alert || badge || sound)
        errors.add(:priority, 'Priority should be 5 if content_available = 1 and no alert/badge/sound')
      end
    end
  end
end
