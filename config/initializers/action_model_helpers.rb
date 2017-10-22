module ActionView
  # = Active Model Helpers
  module Helpers
    module ActiveModelHelper
    end

    module ActiveModelInstanceTag
      def object
        @active_model_object ||= begin
          object = super
          object.respond_to?(:to_model) ? object.to_model : object
          # raise
        end
      end

      def content_tag(*)
        # raise
        error_wrapping(super)
      end

      def tag(type, options, *)
        # raise
        tag_generate_errors?(options) ? error_wrapping(super) : super
      end

      def error_wrapping(html_tag)
        # raise if @method_name == name || @method_name == free_texts || @method_name == free_form || @method_name == free_form_attributes
        if object_has_errors?

          Base.field_error_proc.call(html_tag, self)
        else
          html_tag
        end
      end

      def error_message
        # raise if @method_name == 'free_texts' || @method_name == 'free_form' || @method_name == 'free_form_attributes'
        object.errors[@method_name]
      end

      private

      def object_has_errors?
        object.respond_to?(:errors) && object.errors.respond_to?(:[]) && error_message.present?
        # object.respond_to?(:errors) && object.errors.respond_to?(:[])
      end

      def tag_generate_errors?(options)
        options['type'] != 'hidden'
      end
    end
  end
end
