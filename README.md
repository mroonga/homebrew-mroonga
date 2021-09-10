# The Homebrew formula for Mroonga

Type the following command to install Mroonga by Homebrew:

With MySQL 8.0:

    % brew tap mroonga/mroonga
    % brew install mroonga --with-homebrew-mysql --no-sandbox

With MySQL 5.7:

    % brew tap mroonga/mroonga
    % brew install mroonga --with-homebrew-mysql@5.7 --no-sandbox

With MariaDB:

    % brew tap mroonga/mroonga
    % brew install mroonga --with-homebrew-mariadb --no-sandbox

If you have an old formulae, please unlink to the old formulae version:

    % brew services stop [formulae]
    % brew unlink [formulae]
    % mv /usr/local/var/[formulae] /usr/local/var/[formulae_version]

If you want to use this formula with MySQL built by yourself instead of MySQL installed by Homebrew:

    % curl -O https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-boost-8.0.26.tar.gz
    % tar xvzf mysql-boost-8.0.26.tar.gz
    % cd mysql-8.0.26
    % cmake -DCMAKE_INSTALL_PREFIX=$HOME/local/mysql-8.0.26
    % make -j$(/usr/sbin/sysctl -n hw.ncpu)
    % make install
    % cd ~/local/mysql-8.0.26
    % scripts/mysql_install_db
    % bin/mysqld_safe &
    % cd -
    % brew tap mroonga/mroonga
    % PATH="$HOME/local/mysql-8.0.26/bin:$PATH" brew install mroonga --with-mysql-source=$(pwd)
