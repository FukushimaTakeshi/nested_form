require 'rails_helper'

# RSpec.describe Entry, type: :model do

  describe 'StringTypeValidator' do
    let(:model_class) do
      Struct.new(:text) do
        include ActiveModel::Validations
        include Validators

        def self.name
          'DummyModel'
        end

        validates :text, string_type: true
      end
    end

    describe 'validate_each' do
      subject { model_class.new(text) }

      context 'without string type' do
        let(:text) { 'ああ①ああ' }
        it 'エラー' do
          should_not be_valid
        end
      end
      context 'with string type' do
        let(:text) { 'ああああ' }
        it '正常' do
          should be_valid
        end
      end
    end

    describe 'error messages' do
      subject { object.errors.messages }

      let(:object) { model_class.new('aa①aaaa') }
      before { object.validate }

      it 'エラーメッセージ' do
        is_expected.to eq(text: [I18n.t("activemodel.errors.models.dummy_model.attributes.text.not_a_jisx0208")])
      end
    end
  end
# end
