# Dangerously fast way to publish a patch to NPM
set -e # Stop if anything fails
echo "Enter your npmjs.org credentials."
npm adduser
npm install
VERSION=`./node_modules/grunt/bin/grunt bump:patch |  grep -no 'to .*$' | cut -c 6-`;
./build.sh
git add package.json
git add lib/*.js
git commit -m "Bumped version number to "$VERSION"."
git tag -a v$VERSION -m 'Version '$VERSION
npm publish
git push origin master --tags


