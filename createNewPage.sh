readonly path="source/_posts"
realPath="$path"
cd $path
#第一个参数是page所在的目录的名字，如果为''，则认为没有目录，直接在根目录创建
#如果是根目录，不用做任何操作
#如果为根目录，判断目录是否存在，如果不存在，则直接创建目录
mulu=$1
if [ "$mulu" = "" ];then
	echo "filePath is null"
else
	echo "filePath is $mulu"
	if [ ! -d "$mulu" ];then
		mkdir $mulu
		echo "filePath $mulu is created success"
	else
		echo "filePath $mulu has been exist"
	fi
	realPath="$mulu"
fi
pwd
#第二个参数是page的名字
fileName=$2
hexo new "$fileName"
if [ "$path" != "$realPath" ];then
	mv "$fileName.md" $realPath
	cd $realPath
fi
#第三个参数是categories，也就是目录,如果有多个，用","进行分割
categoriesStr=$3
categoriesArray=(${categoriesStr//,/ })  
for var in ${categoriesArray[@]}
do
   sed -i "" "/categories/a\\	
	  - $var
	" "$fileName.md"
done
#第四个参数时tag，也就是标签，如果有多个，用","进行分割
tagStr=$4
tagArray=(${tagStr//,/ })  
for var in ${tagArray[@]}
do
    sed -i "" "/tags/a\\	
	  - $var
	" "$fileName.md"
done