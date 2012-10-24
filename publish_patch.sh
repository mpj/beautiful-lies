# Dangerously fast way to publish a patch to NPM
npm install
./build.sh
VERSION=`./node_modules/grunt/bin/grunt bump:patch |  grep -no 'to .*$' | cut -c 6-`;
git add package.json
git add lib/*.js
git commit -m "Bumped version number to "$VERSION
git tag -a v$VERSION -m 'Version '$VERSION
git push origin master --tags
npm publish

