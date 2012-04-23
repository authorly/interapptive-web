class String
  def self.from_rgb(rgb)
    '#' << rgb.map { |val| val.to_s(16) }.join
  end

  def to_rgb
    parts = self.delete("#").scan(/[0-9a-f]{2}/i)
    parts.map { |hex| hex.to_i(16) }
  end
end
