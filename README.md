# The Homebrew formula for Mroonga

Type the following command to install Mroonga by Homebrew:

With MySQL 5.7:

    % brew tap mroonga/mroonga
    % brew install mroonga --use-homebrew-mysql --no-sandbox

With MySQL 5.6:

    % brew tap mroonga/mroonga
    % brew install mroonga --use-homebrew-mysql56 --no-sandbox

With MySQL 5.5:

    % brew tap mroonga/mroonga
    % brew install mroonga --use-homebrew-mysql55 --no-sandbox

With MariaDB:

    % brew tap mroonga/mroonga
    % brew install mroonga --use-homebrew-mariadb --no-sandbox

If you have an old formulae, please unlink to the old formulae version:

    % brew services stop [formulae]
    % brew unlink [formulae]
    % mv /usr/local/var/[formulae] /usr/local/var/[formulae_version]

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
    % brew tap mroonga/mroonga
    % PATH="$HOME/local/mysql-5.5.24/bin:$PATH" brew install mroonga --with-mysql-source=$(pwd)
