pwd=`pwd`

if [ ${pwd##*/} == t ] ; then
	echo "cd .."
	cd ..
fi

../../bundle/vim-vspec/bin/vspec ../../bundle/vim-vspec . t/up2date.vim
../../bundle/vim-vspec/bin/vspec ../../bundle/vim-vspec . t/line.vim
