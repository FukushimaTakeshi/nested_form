class FreeForm
  include ActiveModel::Model

  attr_accessor :test, :free_texts

  validate  :free_form_validation

   def free_form_validation
     errors.add(:free_texts, "コメントは10文字以内で入力して下さい。") if free_texts.length > 10
    #  raise
   end

  #  def free_form_attributes=(attributes)
  #    @free_texts ||= []
  #    attributes.each do |_, params|
  #      @free_texts.push(FreeForm.new(params))
  #    end
  #  end

  def text
    [{
      no: 1,
      comment: "コメント１"
    },
    {
      no: 2,
      comment: "コメント２"
    }]
  end
end
