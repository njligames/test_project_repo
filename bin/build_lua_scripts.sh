_pwd=`pwd`

cd $1
luac -s -o ${_pwd}/luac.out `find . -type f -name "*.lua" -exec echo {} \;`

cd ${_pwd}

