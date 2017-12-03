class InquiryController < ApplicationController
  include TransactionToken
  before_action :reset_transaction_token, only: [:new]
  before_action :valid_multi_tabs, except: [:new]


  def new
    @free_form = FreeForm.all
    @inquiry = Inquiry.new(@free_form)
  end

  def confirm
    @free_form = FreeForm.all
    @inquiry = Inquiry.new(@free_form, inquiry_params(@free_form.count))
    render :new unless @inquiry.valid?
  end

  def create
    @free_form = FreeForm.all
    @inquiry = Inquiry.new(@free_form, inquiry_params(@free_form.count))
    @inquiry.save!
  end

  private

  # Strong Parameters
  def inquiry_params(count)
    free_texts_params = count.times.map { |index| "free_text_#{index}".to_sym }
    params.require(:inquiry).permit([:name, :tel, :email] << free_texts_params)
  end

  def reset_transaction_token
    session.delete(:"_transaction_token:#{params[:id]}")
  end

  def valid_multi_tabs
    raise unless verified_transaction_request?
  end
end
