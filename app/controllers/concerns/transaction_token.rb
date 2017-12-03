module TransactionToken
  extend ActiveSupport::Concern

  included do
    helper_method :form_transaction_token
  end

  def verified_transaction_request?
    request.get? || request.head? ||
    valid_transaction_token?(session, form_transaction_param)
  end

  protected

  TRANSACTION_TOKEN_LENGTH = 32

  # viewに埋め込むtoken
  def form_transaction_token
    masked_transaction_token(session)
  end

  private

  def form_transaction_param # :doc:
    params[:transaction_token]
  end

  def valid_transaction_token?(session, encoded_masked_token) # :doc:
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

    if masked_token.length == TRANSACTION_TOKEN_LENGTH
      # This is actually an unmasked token. This is expected if
      # you have just upgraded to masked tokens, but should stop
      # happening shortly after installing this gem.
      compare_with_real_token masked_token, session
    elsif masked_token.length == TRANSACTION_TOKEN_LENGTH * 2
      csrf_token = unmask_token(masked_token)
      compare_with_real_token(csrf_token, session)
    else
      false # Token is malformed.
    end
  end

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
    one_time_pad = masked_token[0...TRANSACTION_TOKEN_LENGTH]
    encrypted_csrf_token = masked_token[TRANSACTION_TOKEN_LENGTH..-1]
    xor_byte_strings(one_time_pad, encrypted_csrf_token)
  end

  def masked_transaction_token(session) # :doc:
    raw_token = real_csrf_token(session)
    one_time_pad = SecureRandom.random_bytes(TRANSACTION_TOKEN_LENGTH)
    encrypted_csrf_token = xor_byte_strings(one_time_pad, raw_token)
    masked_token = one_time_pad + encrypted_csrf_token
    Base64.strict_encode64(masked_token)
  end

  def xor_byte_strings(s1, s2)
    s1.bytes.zip(s2.bytes).map { |(c1, c2)| c1 ^ c2 }.pack('c*')
  end

  def real_csrf_token(session) # :doc:
    session[:"_transaction_token:#{params[:id]}"] ||= SecureRandom.base64(TRANSACTION_TOKEN_LENGTH)
    Base64.strict_decode64(session[:"_transaction_token:#{params[:id]}"])
  end
end
