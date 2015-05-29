#!/bin/sh

if [ $# -ne 1 ]; then
        echo "Usage: $0 version"
        echo " e.g.: $0 2.04"
        exit 1
fi

version=$1

base_name=mroonga-$version.tar.gz

download_base_url=http://packages.groonga.org/source/mroonga
tmp_dir=/tmp/homebrew-mroonga
mroonga_url=$download_base_url/$base_name

rm -rf $tmp_dir
mkdir -p $tmp_dir
chmod og-rwx $tmp_dir
cd $tmp_dir
curl -LO $mroonga_url
sha256=$(openssl dgst -sha256 $base_name | cut -f 2 -d ' ')
cd -
rm -rf $tmp_dir

sed -i'' \
  -e "s,\"http://packages.*\",\"$mroonga_url\"," \
  mroonga.rb
sed -i'' \
  -e "s,sha256 \".*\",sha256 \"$sha256\"," \
  mroonga.rb
