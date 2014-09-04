module StripeWrapper
  class Charge
    attr_reader :response, :status

    def initialize(response, status)
      @response = response
      @status = status
    end

    def self.create(options={})
      begin
        response = Stripe::Charge.create(
          amount: options[:amount], 
          currency: "usd", 
          card: options[:card],
          description: options[:description]
        )
        new(response, :success)
      rescue Stripe::CardError => e
        new(e.message, :error)
      end
    end

    def successful?
      status == :success
    end

    def error_message
      response
    end
  end
end
