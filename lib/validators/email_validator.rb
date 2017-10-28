module Validators
  class EmailValidator < ActiveModel::EachValidator
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :invalid) unless value =~ VALID_EMAIL_REGEX
    end
  end
end
