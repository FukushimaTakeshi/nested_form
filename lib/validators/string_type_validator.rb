module Validators
  class StringTypeValidator < ActiveModel::EachValidator
    REGEXP = /\A#{"[　-╂亜-腕弌-熙]".encode("SHIFT_JIS")}+\z/

    def validate_each(record, attribute, value)
      return if value.blank?
      record.errors.add(attribute, :not_a_jisx0208) unless jisx0208_include?(value)
    end

    private

    def jisx0208_include?(target_string)
      REGEXP.match(target_string.encode("SHIFT_JIS")).present?
    rescue Encoding::UndefinedConversionError
      false
    end
  end
end
