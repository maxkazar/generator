class Generator
  # Return template folder path.
  # @return [String] Template folder path
  #   Can be override in child class
  attr_reader :templates_path

  def self.generator
    @generator ||= []
  end

  def self.inherited(module_class)
    self.generator << module_class
  end

  def initialize(options = {})
    @templates_path = options[:template_path] || File.join(Dir.pwd, 'generators/templates')
    @options = options
  end

  def self.run(group, options = {})
    self.generator.each { |generator| generator.new(options).run if generator.group == group }
  end

  def self.remove(group, options = {})
    self.generator.each { |generator| generator.new(options).remove if generator.group == group }
  end

  # Create new folder
  # @param [String] folder Folder name
  # @param [String] force Remove folder before create if folder exist
  def create_folder(folder, force = false)
    FileUtils.rm_rf folder if force
    FileUtils.makedirs folder unless Dir.exist? folder
  end

  # Remove folder
  # @param [String] folder Folder name
  def remove_folder(folder)
    FileUtils.rm_rf folder if Dir.exist? folder
  end

  # Create new file from template
  # @param [String] path Path to folder
  # @param [String] template_name Template file name
  # @param [String] file_name New file name
  def create_file(path, template_name, file_name = nil)
    template = File.join @templates_path, template_name
    template_file = File.open(template, 'r') { |file| ERB.new(file.read).result binding }
    file_name = File.basename template_name, '.*' if file_name.nil?
    file_name = File.join( path,  file_name)
    File.open(file_name, 'w') { |file| file.write template_file }
  end

  def remove_file(path)
    FileUtils.rm_rf path if File.exist? path
  end
end