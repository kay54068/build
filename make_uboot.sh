#!/bin/bash
function usage() {
	cat >&2 <<- EOF
	******************************************************
	make u-boot for u-boot source

	Usage: ${0} [OPTIONS] [CONFIG]
	
	OPTIONS: 
	 -h: this help message .
	 config [CONFIG]
	 build
	 clean
	 menuconfig
	 saveconfig [CONFIG]
	 list_imx8m_config
	 list_all_config
	CONFIG:
		e.g.:
			imx8mp_evk_defconfig
			imx8mp_ddr4_evk_defconfig
			imx8mm_evk_defconfig
			imx8mm_ddr3l_val_defconfig
	---------------------
	example:
	  ${0} config imx8mp_evk_defconfig
	  ${0} build
	  ${0} clean
	  ${0} menuconfig
	  ${0} saveconfig imx8mp_evk_defconfig
	  ${0} list_imx8m_config
	  ${0} list_all_config
	******************************************************

	EOF
}


_tmp_file="/tmp/${USER}_tmp"
echo -n "" > "${_tmp_file}"
while getopts ":h" opt
do
	case ${opt} in
		h ) 
			usage 
			exit 0 ;; 
		* )
			echo -n "${opt} ${OPTARG} " >> "${_tmp_file}"
			;;
	esac
done
shift "$(expr ${OPTIND} - 1)"

#############################
# 	     variable
#############################
SOURCE_PATH=../uboot-imx
TOOLCHAIN_PATH=/opt/fsl-imx-xwayland/5.10-hardknott/environment-setup-cortexa53-crypto-poky-linux
OPTIONS=$1
CONFIG=$2


#############################
#		functions
#############################
function source_toolchain() {
echo "[source toolvhain]"
source $TOOLCHAIN_PATH
}


#############################
#		Main
#############################
source_toolchain
cd $SOURCE_PATH
LANG="en_US.UTF-8"

case $OPTIONS in
	"config")
		if [ -f configs/$CONFIG ]; then
			echo "[make config] $CONFIG"
			# result=$(make $CONFIG 2>&1)
			result=$(make $CONFIG)
			if [[ $? != 0 ]]; then
				echo "make config fail"
				exit 1
			fi
		else
			echo "parameter2[CONFIG] invalid , pls use list_all_config  or list_imx8m_config to  check config "
			exit 1
		fi
	;;
	"build")
		echo "[make]"
		
		result=`make -j $(nproc)`
		if [[ $? != 0 ]]; then
			echo "make fail!! . pls check to run ${0} config [CONFIG]"
			exit 1
		fi 	
	;;
	# "rebuild")

	# 	echo "[make distclean]"
	# 	make distclean

	# 	if [ -f configs/$CONFIG ]; then
	# 		echo "[make config] $CONFIG"
	# 		# result=$(make $CONFIG 2>&1)
	# 		result=$(make $CONFIG)
	# 		if [[ $? != 0 ]]; then
	# 			echo "make config fail"
	# 			exit 1
	# 		fi
	# 	else
	# 		echo "parameter2[CONFIG] invalid , pls use list_all_config  or list_imx8m_config to  check config "
	# 		exit 1
	# 	fi

	# 	echo "[make]"
	# 	make -j $(nproc)
	# ;;
	"clean")
		echo "[make distclean]"
		make distclean
		exit 0
	;;
	"menuconfig")
		make menuconfig
	;;
	"savedefconfig")
		if [ -f configs/$CONFIG ]; then
			make savedefconfig
			cp defconfig configs/$CONFIG
		else
			echo "parameter2[CONFIG] invalid , pls use list_all_config  or list_imx8m_config to  check config "
		fi
	;;
	"list_imx8m_config")
		ls -v configs/ | grep "imx8m"
		exit 0
	;;
	"list_all_config")
		ls -v configs/
		exit 0
	;;
	*)
		echo "parameter1[OPTIONS] must be build, rebuild, clean, list_imx8m_config, list_all_config"
	;;
esac

