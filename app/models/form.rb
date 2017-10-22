class Form
  include ActiveModel::Model

  attr_accessor :text

  validate  :free_form_validation

   def free_form_validation
     text if text.length > 10
     errors.add(:text, "コメントは10文字以内で入力して下さい。")
   end

   def text_attributes=(attributes)
     @text ||= []
     attributes.each do |_, params|
       @text.push(Form.new(params))
     end
   end
end
