module Auth0
  class Auth0UpdateBody

    attr_reader :name, :blocked

    def initialize(name=nil, status=nil)
      @name = name
      @blocked = blocked_value_from_status(status)
    end

    def body_request
      {
        name:,
        blocked:,
      }.compact
    end

    private

    def blocked_value_from_status(status)
      return if status.nil?
      case status.to_s.to_sym
      when :active
        false
      when :disabled
        true
      else
        nil
      end
    end
  end
end