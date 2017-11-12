class EntryController < ApplicationController

  def new
    @free_form = FreeForm.new
    @entry = Entry.new(@free_form.text)
  end

  def confirm
    @free_form = FreeForm.new
    @entry = Entry.new(@free_form.text, entry_params(@free_form.text.size))
    render :new unless @entry.valid?
  end

  def finish
    @entry = Entry.new(entry_params)
    @entry.save
  end

  private
    # Strong Parameters
    def entry_params(texts_size)
      free_texts_params = texts_size.times.map { |index| "free_text_#{index}".to_sym }
      params.require(:entry).permit([:name, :name_katakana, :tel, :email] << free_texts_params)
    end
end
