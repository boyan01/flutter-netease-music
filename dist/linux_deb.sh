#!/bin/bash

app_name="quiet"
current_dir=$(dirname "$0")

project_dir="${current_dir}/.."
package_dir="${project_dir}/build/deb_package"

rm -rf "${package_dir}"

control_file="${current_dir}/deb/DEBIAN/control"

# read version from pubspec.yaml
version=$(cat "${project_dir}/pubspec.yaml" | grep "^version:" | awk '{print $2}' | tr -d '"')
version=$(echo "${version}" | sed 's/+.*//')

# check version only contains numbers and dots
if ! [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format: ${version}"
  exit 1
fi

echo "update control file with version: ${version}"
# update control file version
sed -i "s/Version:.*/Version: ${version}/g" "${control_file}"

cp -fr "$current_dir/deb/." "$package_dir"
mkdir -p "$package_dir/usr/lib/$app_name"
cp -fr "$project_dir/build/linux/x64/release/bundle/." \
  "$package_dir/usr/lib/$app_name"

mkdir -p "$package_dir/usr/bin"
pushd "$package_dir/usr/bin" || exit
ln -s "../lib/$app_name/$app_name" "$app_name"
popd || exit

dpkg-deb --build --root-owner-group "$package_dir" "$project_dir/build/${app_name}_amd64.deb"