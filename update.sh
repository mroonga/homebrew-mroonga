#!/bin/sh

if [ $# -ne 1 ]; then
        echo "Usage: $0 version"
        echo " e.g.: $0 2.04"
        exit 1
fi

version=$1

base_name=mroonga-$version.tar.gz

github_base_url=https://github.com/downloads/mroonga/mroonga
tmp_dir=/tmp/homebrew-mroonga
mroonga_url=$github_base_url/$base_name

rm -rf $tmp_dir
mkdir -p $tmp_dir
chmod og-rwx $tmp_dir
cd $tmp_dir
curl -LO $mroonga_url
md5=$(openssl dgst -md5 $base_name | cut -f 2 -d ' ')
cd -
rm -rf $tmp_dir

sed -i'' \
  -e "s,'https:.*','$mroonga_url'," \
  mroonga.rb
sed -i'' \
  -e "s,md5 '.*',md5 '$md5'," \
  mroonga.rb
