module EntryHelper

  def sort_messages(messages, size = 3)
    ref = { name: 0, name_katakana: 1, tel: 2, email: 99 }
    size.times.map { |size_index| { "free_text_#{size_index}": 3 + size_index } }.each do |val|
      ref.merge!(val)
    end
    messages.sort { |val1, val2| ref[val1[0]] <=> ref[val2[0]] }.to_h.keys
  end
end
