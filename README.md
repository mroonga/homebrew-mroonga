The homebrew formula for mroonga
================================

Type the following command to install mroonga by homebrew:

    % brew install https://raw.github.com/mroonga/homebrew/master/mroonga.rb --use-homebrew-mysql

If you want to use this formula with MySQL built by yourself instead of MySQL installed by homebrew:

    % wget http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.5/mysql-5.5.24.tar.gz
    % tar xvzf mysql-5.5.24.tar.gz
    % cd mysql-5.5.24
    % cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql-5.5.24
    % brew install https://raw.github.com/mroonga/homebrew/master/mroonga.rb --with-mysql-source=$PWD

