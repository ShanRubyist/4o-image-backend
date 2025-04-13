class PayProcessJob < ApplicationJob
  queue_as :default

  def perform(args)
    sync_charge(args)
  end
end

# 迷瞪算法
# 金额校验
# # customer 什么时候创建的
#
# subscription 什么时候创建的

def sync_charge(checkout_id)
  # Skip loading the latest charge details from the API if we already have it
  # @client ||= Faraday.new(url: 'https://test-api.creem.io/')
  # resp = @client.get('/v1/checkouts?checkout_id=' + checkout_id) do |req|
  #   req.headers['x-api-key'] = ENV.fetch('CREEM_API_KEY')
  #   req.headers['Content-Type'] = 'application/json'
  # end
  obj = {
    "id": "<string>",
    "mode": "test",
    "object": "<string>",
    "status": "completed",
    "request_id": "<string>",
    "product": {},
    "units": 123,
    "order": {
      "id": "<string>",
      "mode": "test",
      "object": "<string>",
      "customer": {},
      "product": {},
      "amount": 2000,
      "currency": "EUR",
      "fx_amount": 15,
      "fx_currency": "EUR",
      "fx_rate": 1.2,
      "status": "pending",
      "type": "subscription",
      "affiliate": "<string>",
      "created_at": "2023-09-13T00:00:00Z",
      "updated_at": "2023-09-13T00:00:00Z"
    },
    "subscription": {},
    "customer": {
      'email': 'nianshan1989@gmail.com'
    },
    "custom_fields": [
      {
        "type": "<string>",
        "key": "<string>",
        "label": "<string>",
        "optional": true,
        "text": {
          "max_length": 123,
          "min_length": 123
        }
      }
    ],
    "checkout_url": "<string>",
    "success_url": "https://example.com/return",
    "feature": [
      {
        "license": {
          "id": "<string>",
          "mode": "test",
          "object": "<string>",
          "status": "active",
          "key": "ABC123-XYZ456-XYZ456-XYZ456",
          "activation": 5,
          "activation_limit": 1,
          "expires_at": "2023-09-13T00:00:00Z",
          "created_at": "2023-09-13T00:00:00Z",
          "instance": [
            {
              "id": "<string>",
              "mode": "test",
              "object": "license-instance",
              "name": "My Customer License Instance",
              "status": "active",
              "created_at": "2023-09-13T00:00:00Z"
            }
          ]
        }
      }
    ],
    "metadata": [
      {}
    ]
  }
  require 'recursive_open_struct'
  object = RecursiveOpenStruct.new(obj, recurse_over_arrays: true)

  if true #resp.success?
    # object = JSON.load(resp.body)

    # Ignore transactions that aren't completed
    return unless object.status == "completed"

    # Ignore charges without a Customer
    return if object&.customer&.id&.blank?

    pay_customer = Pay::Customer.find_by(processor: :creem, processor_id: object&.customer&.email)
    return unless pay_customer

    # # Ignore transactions that are payment method changes
    # # But update the customer's payment method
    # if object.origin == "subscription_payment_method_change"
    #   Pay::PaddleBilling::PaymentMethod.sync(pay_customer: pay_customer, attributes: object.payments.first)
    #   return
    # end

    attrs = {
      amount: object.order.amount,
      created_at: object.order.created_at,
      currency: object.order.currency,
      metadata: object.metadata,
      subscription: pay_customer.subscriptions.find_by(processor_id: object.subscription.id)
    }

    # if object.payment
    #   case object.payment.method_details.type.downcase
    #   when "card"
    #     attrs[:payment_method_type] = "card"
    #     attrs[:brand] = details.card.type
    #     attrs[:exp_month] = details.card.expiry_month
    #     attrs[:exp_year] = details.card.expiry_year
    #     attrs[:last4] = details.card.last4
    #   when "paypal"
    #     attrs[:payment_method_type] = "paypal"
    #   end
    #
    #   # Update customer's payment method
    #   Pay::PaddleBilling::PaymentMethod.sync(pay_customer: pay_customer, attributes: object.payments.first)
    # end

    # Update or create the charge
    if (pay_charge = pay_customer.charges.find_by(processor_id: object.id))
      pay_charge.with_lock do
        pay_charge.update!(attrs)
      end
      pay_charge
    else
      # pay_customer.charges.create!(attrs.merge(processor_id: object.id))

      Pay::Charge.create!(attrs.merge(processor_id: object.id, customer_id: pay_customer.id))
    end
  else
    fail 'creem callback fail:' + resp.inspect
  end
end