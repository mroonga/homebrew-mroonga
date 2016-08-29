# -*- coding: utf-8 -*-
class Mroonga < Formula
  homepage "http://mroonga.org/"
  url "http://packages.groonga.org/source/mroonga/mroonga-6.08.tar.gz"
  sha256 "ffaae0b3bd1f2f67600301684c569ae30b03ee5a455cb4d90ddef4db857eefa1"

  depends_on "pkg-config" => :build

  option "use-homebrew-mysql", "Use MySQL installed by Homebrew."
  option "use-homebrew-mariadb", "Use MariaDB installed by Homebrew. You can't use this option with use-homebrew-mysql."
  option "with-mecab", "Use MeCab installed by Homebrew. You can use additional tokenizer - TokenMecab. Note that you need to build Groonga with MeCab"
  option "with-mysql-source=PATH", "MySQL source directory. You can't use this option with use-homebrew-mysql and use-homebrew-mariadb"
  option "with-mysql-build=PATH", "MySQL build directory (default: guess from with-mysql-source)"
  option "with-mysql-config=PATH", "mysql_config path (default: guess from with-mysql-source)"
  option "with-debug[=full]", "Build with debug option"
  option "with-default-parser=PARSER", "Specify the default fulltext parser like with-default-parser=TokenMecab (default: TokenBigram)"

  if build.with?("mecab")
    depends_on "groonga" => "--with-mecab"
  else
    depends_on "groonga"
  end

  if build.include?("use-homebrew-mysql")
    depends_on "cmake" => :build
    depends_on "boost" => :build
    depends_on "mysql"
  elsif build.include?("use-homebrew-mariadb")
    depends_on "cmake" => :build
    depends_on "mariadb"
  end

  def patches
    [
    ]
  end

  def install
    if build.include?("use-homebrew-mysql")
      mysql_formula_name = "mysql"
    elsif build.include?("use-homebrew-mariadb")
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
        raise "--use-homebrew-mysql, --use-homebrew-mariadb or --with-mysql-source=PATH is required"
      end
      install_mroonga(mysql_source_path, nil)
    end
  end

  test do
  end

  def caveats
    <<-EOS.undent
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
      return super if data_index.nil?

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
    formula.brew do
      formula.patch
      formula.install(:dry_run => true)
      yield formula
    end
  end

  def build_configure_args(mysql_source_path, mysql_config_path)
    configure_args = [
      "--prefix=#{prefix}",
      "--with-mysql-source=#{mysql_source_path}",
    ]

    mysql_config = option_value("--with-mysql-config")
    mysql_config ||= mysql_config_path
    if mysql_config
      configure_args << "--with-mysql-config=#{mysql_config}"
    end

    mysql_build_path = option_value("--with-mysql-build")
    if mysql_build_path
      configure_args << "--with-mysql-build=#{mysql_build_path}"
    end

    debug = option_value("--with-debug")
    if debug
      if debug == true
        configure_args << "--with-debug"
      else
        configure_args << "--with-debug=#{debug}"
      end
    end

    default_parser = option_value("--with-default-parser")
    if default_parser
      configure_args << "--with-default-parser=#{default_parser}"
    end

    configure_args
  end

  def install_mroonga(mysql_source_path, mysql_config_path)
    configure_args = build_configure_args(mysql_source_path, mysql_config_path)
    system("./configure", *configure_args)
    system("make")
    system("make", "install")
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
