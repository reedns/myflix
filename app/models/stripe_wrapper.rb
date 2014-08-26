module StripeWrapper
  class Charge
    attr_reader :response, :status

    def initialize(response, status)
      @response = response
      @status = status
    end

    def self.create(options={})
      StripeWrapper.api_key
      begin
        response = Stripe::Charge.create(
          amount: options[:amount], 
          currency: "usd", 
          card: options[:card],
          description: options[:description]
        )
        new(response, :sucess)
      rescue Stripe::CardError => e
        new(e.message, :error)
      end
    end

    def successful?
      status != :error
    end

    def error_message
      response
    end
  end

  def self.api_key 
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
  end
end
