class Array
  def sum
    self.compact.inject(0) { |s,v| s += v }
  end
  
  def to_i
    self.collect{|x| x.to_i}
  end
  
  def to_f
    self.collect{|x| x.to_i}
  end
  
  def frequencies
    new_val = {}
    self.each do |s|
      elem = s.to_s
      new_val[elem].nil? ? new_val[elem]=1 : new_val[elem]+=1
    end
    return new_val
  end
  
  def chunk(pieces=2)
    len = self.length
    return [] if len == 0
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << self[start..last] || []
      start = last+1
    end
    chunks
  end
  
  def repack
    set = []
    self.each do |slice|
      set<<slice
      yield set
    end
  end
  
  def centroid
    dimensions = self.flatten
    x_cent = (x_vals = 1.upto(dimensions.length).collect{|x| dimensions[x] if x.even?}.compact).sum/x_vals.length
    y_cent = (y_vals = 1.upto(dimensions.length).collect{|y| dimensions[y] if !y.even?}.compact).sum/y_vals.length
    return x_cent, y_cent
  end
  
  def area
    side_one = (self[0].to_f-self[2].to_f).abs
    side_two = (self[1].to_f-self[3].to_f).abs
    return side_one*side_two
  end
  
  def all_combinations(length_range=1..self.length)
    permutations = []
    length_range.max.downto(length_range.min) do |length|
      self.permutation(length).each do |perm|
        permutations << perm.sort if !permutations.include?(perm.sort)
      end
    end
    return permutations
  end
  
  def structs_to_hashes
    keys = (self.first.methods-Class.methods).collect{|x| x.to_s.gsub("=", "") if x.to_s.include?("=") && x.to_s!= "[]="}.compact
    hashed_set = []
    self.each do |struct|
      object = {}
      keys.collect{|k| object[k] = k.class == DateTime ? struct.send(k).to_time : struct.send(k)}
      hashed_set << object
    end
    return hashed_set
  end
  
  def sth
    structs_to_hashes
  end
end

class Fixnum
  
  def days
    return self*60*60*24
  end
  
  def day
    return days
  end
  
  def weeks
    return self*60*60*24*7
  end
  
  def week
    return weeks
  end

  def generalized_time_factor
    if self < 60
      #one second
      return 1
    elsif self < 3600
      #one minute
      return 60
    elsif self < 86400
      #one hour
      return 3600
    elsif self < 604800
      #one day
      return 86400
    elsif self < 11536000
      #one week
      return 604800
    else 
      #four weeks
      return 2419200
    end
  end

end

class Time
  def self.ntp
    return self.at(self.now.to_f)
  end

  def gmt
    return to_time.gmtime
  end
end
class String

  require 'rubygems'
  require 'htmlentities'

  def write(str)
    self << str
  end
  
  def underscore
    self.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end
  
  def pluralize
    self.underscore.concat("s")
  end
      
  def sanitize_for_streaming
    # return self.split("").reject {|c| c.match(/[\w\'\-]/).nil?}.to_s
    return self.gsub(/[\'\"]/, '').gsub("#", "%23").gsub(' ', '%20')
  end

  def classify
    if self.split(//).last == "s"
      if self.split(//)[self.split(//).length-3..self.split(//).length].join == "ies"
        camelize(self.split(//)[0..self.split(//).length-4].join("")+"y")
      else
        camelize(self.sub(/.*\./, '').chop)
      end
    else
      camelize(self.sub(/.*\./, ''))
    end
  end

  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
  
  def constantize
    return Object.const_defined?(self) ? Object.const_get(self) : Object.const_missing(self)
  end
  
  def to_class
    return self.classify.constantize
  end
  
  def super_strip
    #This regexp is used in place of \W to allow for # and @ signs.
     if self.include?("#") || self.include?("@")
       return self
     elsif self.include?("http")
       return self
     else
       return self.strip.downcase.gsub(/[!$%\*&:.\;{}\[\]\(\)\-\_+=\'\"\|<>,\/?~`]/, "")
     end
  end
  
  def super_split(split_char)
    #This regexp is used in place of \W to allow for # and @ signs.
    return self.gsub(/[!$%\*\;{}\[\]\(\)\+=\'\"\|<>,~`]/, " ").split(split_char)
  end
  
  def blank?
    return self.empty? || self.nil?
  end
end

class NilClass
  def empty?
    return true
  end
  
  def blank?
    return true
  end
end

class Hash
  def flat_each(prefix=[], &blk)
    each do |k,v|
      if v.is_a?(Hash)
        v.flat_each(prefix+[k], &blk)
      else
        yield prefix+[k], v
      end
    end
  end
  
  def flatify
    hh = {}
    self.to_enum(:flat_each).collect { |k,v| [k.join("-"),v] }.collect {|attrib| hh[attrib[0]] = attrib[1]}
    return hh
  end
  
  def highest
    high_pair = self.max {|a,b| a[1] <=> b[1]}
    return {high_pair[0] => high_pair[1]}
  end
  
  def lowest
    low_pair = self.min {|a,b| a[1] <=> b[1]}
    return {low_pair[0] => low_pair[1]}
  end
  
  def self.zip(keys, values, default=nil, &block)
    hsh = block_given? ? Hash.new(&block) : Hash.new(default)
    keys.zip(values) { |k,v| hsh[k]=v }
    hsh
  end
end
