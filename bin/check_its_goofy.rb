class CheckItsGoofy
  def initialize(path)
    @path = path
  end

  def execute!
    begin
      file = File.read(@path + '/Gemfile')
    rescue
      return false
    end
    exsits = file.scan /goofy/
    !exsits.empty?
  end
end
