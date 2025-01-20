class Api::V1::PaymentsController < ApplicationController
  require 'mercadopago'

  def create_subscription
    sdk = Mercadopago::SDK.new(ENV['MERCADOPAGO_ACCESS_TOKEN'])

    required_params = %w[card_token email plan_id]
    #unless required_params.all? { |param| params[param].present? }
    #  return render json: { error: 'Faltan parámetros obligatorios' }, status: :bad_request
    #end

    preapproval_data = {
      reason: 'Yoga classes',
      external_reference: 'YG-1234',
      preapproval_plan_id: params[:plan_id],
      card_token_id: params[:card_token],
      payer_email: params[:email],
      auto_recurring: {
        frequency: 1,
        frequency_type: 'months',
        start_date: '2023-06-02T13:07:14.260Z',
        end_date: "2023-07-20T15:59:52.581Z",
        transaction_amount: 100,
        currency_id: 'ARS'
      },
      back_url: 'https://www.mercadopago.com.ar',
      status: 'authorized'
    }

    subscription = sdk.preapproval.create(preapproval_data)
    p subscription

    if subscription[:status] == '201'
      render json: {
        subscription_id: subscription[:response]['id'],
        status: subscription[:response]['status']
      }, status: :created
    else
      render json: { error: subscription[:response]['message'] }, status: :unprocessable_entity
    end
  end

  def create_preference
    sdk = Mercadopago::SDK.new(ENV['MERCADOPAGO_ACCESS_TOKEN'])
    

    # Datos de la preferencia
    preference_data = {
      items: [
        {
          title: params[:title], # Título del producto
          quantity: params[:quantity].to_i, # Cantidad
          currency_id: 'ARS', # Moneda (ejemplo: ARS para pesos argentinos)
          unit_price: params[:unit_price].to_f # Precio unitario
        }
      ],
      payer: {
        email: params[:email] # Correo del cliente
      },
      back_urls: {
        success: 'https://tu-frontend.com/success',
        failure: 'https://tu-frontend.com/failure',
        pending: 'https://tu-frontend.com/pending'
      },
      auto_return: 'approved' # Redirección automática al aprobarse
    }

    # Crear la preferencia
    preference = sdk.preference.create(preference_data)

    if preference[:status] == '201'
      render json: { preference_id: preference[:response]['id'] }, status: :ok
    else
      render json: { error: preference[:response]['message'] }, status: :unprocessable_entity
    end
  end

  def webhook
    notification = request.raw_post
    Rails.logger.info("Webhook received: #{notification}")
    head :ok # Responder con un 200 OK para confirmar recepción
  end
end
