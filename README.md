The Homebrew formula for mroonga
================================

Type the following command to install mroonga by Homebrew:

    % brew install https://raw.github.com/mroonga/homebrew/master/mroonga.rb --use-homebrew-mysql

With MariaDB:

    % brew install https://raw.github.com/mroonga/homebrew/master/mroonga.rb --use-homebrew-mariadb

If you want to use this formula with MySQL built by yourself instead of MySQL installed by Homebrew:

    % curl -O http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.5/mysql-5.5.24.tar.gz
    % tar xvzf mysql-5.5.24.tar.gz
    % cd mysql-5.5.24
    % curl http://bazaar.launchpad.net/~mysql/mysql-server/5.5/diff/3806 | patch -p0
    % cmake -DCMAKE_INSTALL_PREFIX=$HOME/local/mysql-5.5.24
    % make -j$(/usr/sbin/sysctl -n hw.ncpu)
    % make install
    % cd ~/local/mysql-5.5.24
    % scripts/mysql_install_db
    % bin/mysqld_safe &
    % cd -
    % PATH="$HOME/local/mysql-5.5.24/bin:$PATH" brew install https://raw.github.com/mroonga/homebrew/master/mroonga.rb --with-mysql-source=$(pwd)
