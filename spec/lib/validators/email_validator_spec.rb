require 'rails_helper'

RSpec.describe Entry, type: :model do

  describe 'EmailValidator' do
    let(:model_class) do
      Struct.new(:email) do
        include ActiveModel::Validations
        include Validators

        def self.name
          'DummyModel'
        end

        validates :email, email: true
      end
    end

    describe 'validate_each' do
      subject { model_class.new(email) }

      context 'without email format' do
        let(:email) { 'aaaacom' }
        it 'エラー' do
          should_not be_valid
        end
      end
      context 'with email format' do
        let(:email) { 'aaaa@example.com' }
        it '正常' do
          should be_valid
        end
      end
    end

    describe 'error messages' do
      subject { object.errors.messages }

      let(:object) { model_class.new('aaaaaa') }
      before { object.validate }

      it 'エラーメッセージ' do
        is_expected.to eq(email: [I18n.t("activemodel.errors.models.dummy_model.attributes.email.invalid")])
      end
    end

  end
end
