#!/usr/bin/env bash

function rollback {
	echo "Rollbacking $path/$1..."
	mv $path/$1 $path/$1.bad
	rm -rf $path/$1.bad
}

function showHelp {
	echo "Run with -p param"
}

function deploy {

	if [ $1 != "master" ]; then
		param="-v"
	fi

	for branch in `git branch -a | grep remotes | grep -v HEAD | grep $param master | grep "$1"`; do

		echo -e "\n\e[1mDownloading $branch from GIT...\e[21m"
		if [ $cloned == 1 ]; then
			git branch --track ${branch#remotes/origin/} $branch
		fi

		dir=$(echo $branch| cut -d'/' -f 3)

		git checkout $dir
		git pull --rebase

		if [ $2 == "CMS" ]; then
			dir="CMS"
		fi

		if [ $2 == "Backend" ]; then
			dir="CmsWriter"
		fi

		echo -e "\n\e[1mCreating $path/$dir.new...\e[21m"
		cp -rf $path/$dir $path/$dir.new
		rm -rf $path/$dir.new/temp
		rm -rf $path/$dir.new/log
		cp -rf . $path/$dir.new
		rm -rf $path/$dir.new/.git
		mkdir -m 777 $path/$dir.new/temp
		mkdir -m 777 $path/$dir.new/log

		echo -e "\n\e[1mCompiling CoffeeScript...\e[21m"
		coffee -c $path/$dir.new
		if [ $dir == "CmsWriter" ]; then
			stylus --compress $path/$dir.new/htdocs/stylus/
		fi

		echo -e "\n\e[1mDeploying...\r"
		if [ ! -d $path/$dir ]; then
			mkdir $path/$dir
		fi
		mv $path/$dir $path/$dir.old
		mv $path/$dir.new $path/$dir

		if [ $2 != "Frontend" ]; then
			echo -e "\n\e[1mUpdating config of $dir...\e[21m"
			password=$(cat $path/$dir.old/app/config/config.neon | grep "password:")
			sed -i -e "s/\tpassword:/$password/g" $path/$dir/app/config/config.neon
		fi

		echo -e "\n\e[1mTesting deployment...\e[21m"
		www=$dir
		if [ $www == "CMS" ]; then
			www=$(ls $path | grep -m 1 .cz)
		fi

		if [ $www == "CmsWriter" ]; then
			www="cms.freetech.cz/login.html"
		fi

		status=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' $www)
		if [ $status != 200 ]; then
			echo -e "\e[1m\e[91mDeployment failed!\e[39m\e[21m"
			rollback $dir
			exit 1
		fi

		echo -e "\n\e[1mSaving old version of $dir...\e[21m"
		tar -zcf $PWD/../old/$dir-$(date "+%Y%m%d%H%M%S").tar.gz $path/$dir.old
		rm -rf $path/$dir.old

		echo -e "\n\e[1m\e[92m$dir was successfully deployed.\e[39m\e[21m\n"

	done
}

while [[ $# -gt 0 ]]
	do
		key="$1"

		case $key in
	    -p|--project)
	      project="$2"
	      shift # past argument
	    ;;
	    -h|--help)
				showHelp
				exit
	    ;;
	    *)
	      showHelp
	    ;;
		esac
	shift # past argument or value
done
if [ ! $project ]; then
	showHelp
	exit;
fi

if [ $project == 'all' ]; then
	project=".*"
fi

repository="Frontend"
if [ $project == "cms" ]; then
	repository="CMS"
	project="master"
fi

if [ $project == "writer" ] || [ $project == "backend" ]; then
	repository="Backend"
	project="master"
fi

cloned=0
path=/var/www/html

if [ ! -d $repository ]; then
	git clone git@github.com:claryaldringen/$repository.git
	cloned=1
fi

cd $repository

if [ $repository == "Frontend" ]; then
	echo -e "Will be installed\n"
	git branch -a | grep remotes | grep -v HEAD | grep -v master | grep "$project"
	echo -e "\nfrom\n"
	git branch -a | grep remotes | grep -v HEAD | grep -v master
fi

echo ""

read -p "Do you wish to deploy this projects? (Y/N) " yn
case $yn in
  [AaYy]* ) deploy $project $repository ;;
  [Nn]* ) exit;;
  * ) echo "Please answer yes or no.";;
esac

