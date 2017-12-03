module ApplicationHelper
  def transaction_token_meta_tags
    tag("meta", name: "transaction-token", content: form_transaction_token).html_safe
  end

  def transaction_token_tags
    token ||= form_transaction_token
    tag(:input, type: "hidden", name: "transaction_token", value: token).html_safe
  end
end
