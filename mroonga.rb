class Mroonga < Formula
  homepage "https://mroonga.org/"
  url "https://packages.groonga.org/source/mroonga/mroonga-11.06.tar.gz"
  sha256 "6a3131950e91b1067f97a18054421eafab4676dc67424b00823ea72b206e2f5f"
  license "LGPLv2+"
  head "https://github.com/mroonga/mroonga.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build

  option "with-homebrew-mysql", "Use MySQL installed by Homebrew."
  option "with-homebrew-mysql@5.7", "Use MySQL@5.7 installed by Homebrew."
  option "with-homebrew-mariadb", "Use MariaDB installed by Homebrew."
  option "with-mysql-source=PATH", "MySQL source directory. You can't use this option with use-homebrew-mysql, use-homebrew-mysql56 and use-homebrew-mariadb"
  option "with-mysql-build=PATH", "MySQL build directory (default: guess from with-mysql-source)"
  option "with-mysql-config=PATH", "mysql_config path (default: guess from with-mysql-source)"
  option "with-debug[=full]", "Build with debug option"
  option "with-default-tokenizer=TOKENIZER", "Specify the default fulltext tokenizer like with-default-tokenizer=TokenMecab (default: TokenBigram)"

  depends_on "groonga"

  if build.with?("homebrew-mysql")
    depends_on "boost" => :build
    depends_on "mysql"
  elsif build.with?("homebrew-mysql@5.7")
    depends_on "boost" => :build
    depends_on "mysql@5.7"
  elsif build.with?("homebrew-mariadb")
    depends_on "boost" => :build
    depends_on "mariadb"
  end

  def install
    if build.with?("homebrew-mysql")
      mysql_formula_name = "mysql"
    elsif build.with?("homebrew-mysql@5.7")
      mysql_formula_name = "mysql@5.7"
    elsif build.with?("homebrew-mariadb")
      mysql_formula_name = "mariadb"
    else
      mysql_formula_name = nil
    end

    if mysql_formula_name
      build_formula(mysql_formula_name) do |formula|
        Dir.chdir(buildpath.to_s) do
          install_mroonga(formula.buildpath.to_s,
                          (formula.prefix + "bin" + "mysql_config").to_s)
        end
      end
    else
      mysql_source_path = option_value("--with-mysql-source")
      if mysql_source_path.nil?
        raise "--with-homebrew-mysql, --with-homebrew-mysql@5.7, --with-homebrew-mariadb or --with-mysql-source=PATH is required"
      end
      install_mroonga(mysql_source_path, nil)
    end
  end

  test do
  end

  def caveats
    <<~EOS
      To confirm successfuly installed, run the following command
      and confirm that 'Mroonga' is in the list:

         mysql> SHOW PLUGINS;
         +---------+--------+----------------+---------------+---------+
         | Name    | Status | Type           | Library       | License |
         +---------+--------+----------------+---------------+---------+
         | ...     | ...    | ...            | ...           | ...     |
         | Mroonga | ACTIVE | STORAGE ENGINE | ha_mroonga.so | GPL     |
         +---------+--------+----------------+---------------+---------+
         XX rows in set (0.00 sec)

      To install Mroonga plugin manually, run the following command:
         mysql -uroot < '#{install_sql_path}'

      To uninstall Mroonga plugin, run the following command:
         mysql -uroot < '#{uninstall_sql_path}'
    EOS
  end

  private
  module Patchable
    def patches
      file_content = path.open do |file|
        file.read
      end
      data_index = file_content.index(/^__END__$/)
      if data_index.nil?
        # Prevent NoMethodError
        return defined?(super) ? super : []
      end

      data = path.open
      data.seek(data_index + "__END__\n".size)
      data
    end
  end

  module DryInstallable
    def install(options={})
      if options[:dry_run]
        catch do |tag|
          @dry_install_tag = tag
          begin
            super()
          ensure
            @dry_install_tag = tag
          end
        end
      else
        super()
      end
    end

    private
    def system(*args)
      if args == ["make", "install"] and @dry_install_tag
        throw @dry_install_tag
      end
      super
    end
  end

  def build_formula(name)
    formula = Formula[name]
    formula.extend(Patchable)
    formula.extend(DryInstallable)
    base_logs = logs
    formula.singleton_class.define_method(:logs) do
      base_logs
    end
    formula.brew do
      formula.patch
      formula.install(:dry_run => true)
      yield formula
    end
  end

  def build_cmake_args(mysql_source_path, mysql_config_path)
    cmake_args = std_cmake_args
    cmake_args << "-DMYSQL_SOURCE_DIR=#{mysql_source_path}"

    mysql_config = option_value("--with-mysql-config")
    mysql_config ||= mysql_config_path
    if mysql_config
      cmake_args << "-DMYSQL_CONFIG=#{mysql_config}"
    end

    mysql_build_path = option_value("--with-mysql-build")
    if mysql_build_path
      cmake_args << "-DMYSQL_BUILD_DIR=#{mysql_build_path}"
    end

    debug = option_value("--with-debug")
    case debug
    when true
      cmake_args << "-DWITH_DEBUG=ON"
    when "full"
      cmake_args << "-DWITH_DEBUG_FULL=ON"
    end

    default_tokenizer = option_value("--with-default-tokenizer")
    if default_tokenizer
      cmake_args << "-DMRN_DEFAULT_TOKENIZER=#{default_tokenizer}"
    end

    cmake_args
  end

  def install_mroonga(mysql_source_path, mysql_config_path)
    cmake_args = build_cmake_args(mysql_source_path, mysql_config_path)
    mkdir "build" do
      system("cmake", "..", "-G", "Ninja", *cmake_args)
      system("ninja", "install")
    end
    system("mysql -uroot < '#{install_sql_path}' || true")
  end

  def data_path
    prefix + "share/mroonga"
  end

  def install_sql_path
    data_path + "install.sql"
  end

  def uninstall_sql_path
    data_path + "uninstall.sql"
  end

  def option_value(search_key)
    build.used_options.each do |option|
      key, value = option.to_s.split(/=/, 2)
      return value || true if key == search_key
    end
    nil
  end
end
