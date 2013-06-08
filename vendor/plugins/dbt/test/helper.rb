$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'test/unit/assertions'
require 'mocha/setup'
require 'dbt'
require 'tmpdir'

class Dbt::TestCase < Minitest::Test
  include Test::Unit::Assertions

  def setup
    Dbt::Config.default_search_dirs = nil
    Dbt::Config.default_no_create = nil
    Dbt::Config.config_filename = nil
    Dbt::Config.datasets_dir_name = nil
    Dbt::Config.repository_config_file = nil
    Dbt::Config.default_up_dirs = nil
    Dbt::Config.default_down_dirs = nil
    Dbt::Config.default_finalize_dirs = nil
    Dbt::Config.default_pre_create_dirs = nil
    Dbt::Config.default_post_create_dirs = nil
    Dbt::Config.default_pre_import_dirs = nil
    Dbt::Config.default_post_import_dirs = nil
    Dbt::Config.default_import_dir = nil
    Dbt::Config.index_file_name = nil
    Dbt::Config.default_import = nil
    Dbt::Config.fixture_dir_name = nil
    Dbt::Config.environment = nil
    Dbt::Config.driver = nil
    Dbt::Config.default_migrations_dir_name = nil
    Dbt::Config.default_database = nil
    Dbt::Config.task_prefix = nil
    ENV["IMPORT_RESUME_AT"] = nil

    @cwd = Dir.pwd
    @base_temp_dir = ENV["TEST_TMP_DIR"] || File.expand_path("#{File.dirname(__FILE__)}/../tmp")
    @temp_dir = "#{@base_temp_dir}/#{name}"
    FileUtils.mkdir_p @temp_dir
    Dir.chdir(@temp_dir)
  end

  def teardown
    Dir.chdir(@cwd)
    FileUtils.rm_rf @base_temp_dir if File.exist?(@base_temp_dir)
    Dbt.database_keys.each do |database_key|
      Dbt.remove_database(database_key)
    end
    Dbt.repository.configuration_data = nil
    Dbt.runtime.reset
  end

  # Create a directory relative to working directory
  def create_dir(filename)
    expanded_filename = "#{working_dir}/#{filename}"
    FileUtils.mkdir_p expanded_filename
    expanded_filename
  end

  # Create a file with specified content relative to working directory
  def create_file(filename, content)
    expanded_filename = "#{working_dir}/#{filename}"
    FileUtils.mkdir_p File.dirname(expanded_filename)
    File.open(expanded_filename, "wb") do |f|
      f.write content
    end
    expanded_filename
  end

  def working_dir
    @temp_dir
  end

  def assert_file_exist(filename)
    assert File.exist?(filename), "File.exist?(#{filename})"
  end
end
