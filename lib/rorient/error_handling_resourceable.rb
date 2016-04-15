module ErrorHandlingResourceable
  def self.included(base)
    base.send(:resources) do
      default_handler do |response|
        if (200...299).include?(response.status)
          next
        elsif response.status == 429
          error = Rorient::RateLimitReached.new("#{response.status}: #{response.body}")
          error.limit = response.headers['RateLimit-Limit']
          error.remaining = response.headers['RateLimit-Remaining']
          error.reset_at = response.headers['RateLimit-Reset']
          error
        else
          error = Rorient::Error.new(Oj.load(response.body))
          error.message
        end
      end
    end
  end
end
