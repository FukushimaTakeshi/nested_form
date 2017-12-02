class InquiryController < ApplicationController
  helper_method :form_transaction_token

  def new
    token_key = params[:id]
    session[:"_transaction_token:#{token_key}"] ||= SecureRandom.base64(24)
    @csrf = Csrf.new(session, params[:id], form_transaction_param)

    @free_form = FreeForm.all
    @inquiry = Inquiry.new(@free_form)
  end

  def confirm
    @csrf = Csrf.new(session, params[:id], form_transaction_param)
    raise unless @csrf.verified_request?(session)

    @free_form = FreeForm.all
    @inquiry = Inquiry.new(@free_form, inquiry_params(@free_form.count))
    render :new unless @inquiry.valid?
  end

  def create
    @csrf = Csrf.new(session, params[:id], form_transaction_param)
    raise unless @csrf.verified_request?
    
    @free_form = FreeForm.all
    @inquiry = Inquiry.new(@free_form, inquiry_params(@free_form.count))
    @inquiry.save!
  end

  # viewに埋め込むtoken
  def form_transaction_token
    @csrf.masked_authenticity_token(session)
  end

  def transaction_protection_token
    :transaction_token
  end

  def form_transaction_param # :doc:
    params[transaction_protection_token]
  end

  private

  # Strong Parameters
  def inquiry_params(count)
    free_texts_params = count.times.map { |index| "free_text_#{index}".to_sym }
    params.require(:inquiry).permit([:name, :tel, :email] << free_texts_params)
  end
end

class Csrf

  AUTHENTICITY_TOKEN_LENGTH = 32

  attr_accessor :session, :id, :form_transaction_param
  def initialize(sessio, id, form_transaction_param)
    self.session = session
    self.id = id
    self.form_transaction_param = form_transaction_param
  end

  # viewに埋め込むtokenのkey
  # def request_forgery_protection_token
  #   :transaction_token
  # end

  # # viewに埋め込むtoken
  # def form_transaction_token
  #   masked_authenticity_token(session)
  # end

  # def form_transaction_param # :doc:
  #   params[request_forgery_protection_token]
  # end

  # GET, HEADの時はチェックしない
  # bodyの'authenticity_token'かheaderの'X-CSRF-Token'を読む
  def verified_request?(tran_senssion)
    # request.get? || request.head? ||
    valid_authenticity_token?(tran_senssion, form_transaction_param) #||
    # valid_authenticity_token?(session, request.headers['X-CSRF-Token'])
    # valid_authenticity_token?(session, encoded_masked_token)
  end

  def valid_authenticity_token?(session, encoded_masked_token) # :doc:
    if encoded_masked_token.nil? || encoded_masked_token.empty? || !encoded_masked_token.is_a?(String)
      return false
    end

    begin
      masked_token = Base64.strict_decode64(encoded_masked_token)
    rescue ArgumentError # encoded_masked_token is invalid Base64
      return false
    end

    # See if it's actually a masked token or not. In order to
    # deploy this code, we should be able to handle any unmasked
    # tokens that we've issued without error.

    if masked_token.length == AUTHENTICITY_TOKEN_LENGTH
      # This is actually an unmasked token. This is expected if
      # you have just upgraded to masked tokens, but should stop
      # happening shortly after installing this gem.
      compare_with_real_token masked_token, session
    elsif masked_token.length == AUTHENTICITY_TOKEN_LENGTH * 2
      csrf_token = unmask_token(masked_token)
      compare_with_real_token(csrf_token, session)
    else
      false # Token is malformed.
    end
  end

  # private

  def compare_with_real_token(token, session) # :doc:
    secure_compare(token, real_csrf_token(session))
  end

  def secure_compare(a, b)
    return false unless a.bytesize == b.bytesize
    l = a.unpack "C#{a.bytesize}"
    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

  def unmask_token(masked_token) # :doc:
    # Split the token into the one-time pad and the encrypted
    # value and decrypt it.
    one_time_pad = masked_token[0...AUTHENTICITY_TOKEN_LENGTH]
    encrypted_csrf_token = masked_token[AUTHENTICITY_TOKEN_LENGTH..-1]
    xor_byte_strings(one_time_pad, encrypted_csrf_token)
  end

  def masked_authenticity_token(session) # :doc:
    raw_token = real_csrf_token(session)
    one_time_pad = SecureRandom.random_bytes(AUTHENTICITY_TOKEN_LENGTH)
    encrypted_csrf_token = xor_byte_strings(one_time_pad, raw_token)
    masked_token = one_time_pad + encrypted_csrf_token
    Base64.strict_encode64(masked_token)
  end

  def xor_byte_strings(s1, s2)
    s1.bytes.zip(s2.bytes).map { |(c1, c2)| c1 ^ c2 }.pack('c*')
  end

  def real_csrf_token(session) # :doc:
    session[:"_transaction_token:#{id}"] ||= SecureRandom.base64(AUTHENTICITY_TOKEN_LENGTH)
    Base64.strict_decode64(session[:"_transaction_token:#{id}"])
  end
end
