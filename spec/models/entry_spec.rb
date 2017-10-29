require 'rails_helper'

RSpec.describe Entry, type: :model do
  LENGTH_MIN_MAX = 5..20
  CHAR = {
    ALPHABETS: [*'A'..'Z', *'a'..'z'],
    HIRAGANA: [*'あ'..'ん'],
    KATAKANA: [*'ア'..'ン'],
    JOUYOUKANJI: [*'一'..'龠'],
    LEVEL3KANJI: [*'螟'..'袞', *'顳'..'颞', *'噓'..'繫']-[*'　'..'╂', *'亜'..'腕', *'弌'..'熙'],
    MARITUKI: [*'①'..'⑳'],
    ROMAN: [*'Ⅰ'..'Ⅻ'],
    OTHER: [
      '㍉', '㌔', '㌢', '㍍', '㌘', '㌧', '㌃', '㌶', '㍑', '㍗', '㌍', '㌦', '㌣', '㌫', '㍊', '㌻', '㎜',
      '㎝', '㎞', '㎎', '㎏', '㏄', '㎡', '㍻', '〝', '〟', '№', '㏍', '℡', '㊤', '㊥', '㊦', '㊧', '㊨', '㈱',
      '㈲', '㈹', '㍾', '㍽', '㍼', '≒', '≡', '∫', '∮', '∑', '√', '⊥', '∠', '∟', '⊿', '∵', '∩', '∪'
    ]
  }
  def random_string(length = Random.rand(LENGTH_MIN_MAX), chars)
    length.times.map { chars.sample }.join
  end

  describe 'valid' do
    subject(:entry) do
      Entry.new(name: name, name_katakana: name_katakana, tel: tel, email: email, free_form: free_form, free_texts: free_texts)
    end
    let(:name) { 'あ' }
    let(:name_katakana) { 'アア' }
    let(:tel) { '1233' }
    let(:email) { 'test@example.com' }
    let(:free_form) { 'あああ' }
    let(:free_texts) { 'いいい' }
    before { entry.validate }

    describe 'name' do
      context '空の場合' do
        let(:name) { '' }
        it 'エラー' do
          should_not be_valid
          expect(entry.errors[:name].size).to eq(1)
        end
      end
      context '21文字以上' do
        let(:name) { random_string(21, CHAR[:HIRAGANA]) }
        it 'エラー' do
          should_not be_valid
          expect(entry.errors[:name].size).to eq(1)
        end
      end
      context '文字種チェック' do
        let(:name) { random_string(20, CHAR[:LEVEL3KANJI]) }
        it 'エラー' do
          should_not be_valid
          expect(entry.errors[:name].size).to eq(1)
        end
      end
      context '21文字以上 & 文字種' do
        let(:name) { random_string(20, CHAR[:HIRAGANA]) + '①' }
        it 'エラー' do
          should_not be_valid
          expect(entry.errors[:name].size).to eq(2)
        end
      end
    end
  end

  describe 'error messages' do
    # subject { object.errors.messages }
    #
    # let(:object) { Entry.new(name: 'aa①aaaa') }
    # before { object.validate }
    #
    # it 'エラーメッセージ' do
    #   is_expected.to eq(name: [I18n.t("activemodel.errors.models.entry.attributes.name.not_a_jisx0208")])
    # end
  end

  # describe 'test' do
    # subject { Entry.new }
    # it { should_not be_valid }
    # it { is_expected.to validate_presence_of(:name) }
  # end
end
