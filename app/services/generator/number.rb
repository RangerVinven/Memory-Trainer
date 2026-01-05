module Generator
  class Number
    def self.call(length:)
      Array.new(length) { rand(0..9) }.join
    end
  end
end
