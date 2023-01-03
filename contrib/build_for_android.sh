RED='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
NC='\033[0m'

#
# https://github.com/Tencent/ncnn/pull/1622
#

cd ../
if [ ! -d "build" ]; then
    mkdir build
fi
rm -rf build/*
cd build

echo -e "${Blue}--> start compile${NC}"
ANDROID_NDK=${ANDROID_HOME}/ndk/25.1.8937393
ANDROID_CMAKE=${ANDROID_HOME}/cmake/3.22.1
# support abi list on windows x64: armeabi-v7a,arm64-v8a,x86,x86_64
ANDROID_ABI="armeabi-v7a,arm64-v8a,x86,x86_64"

NCNN_VULKAN=OFF
ANDROID_PLATFORM_API=21

# If you want to enable Vulkan, platform api version >= android-24 is needed
# NCNN_VULKAN=ON
# ANDROID_PLATFORM_API=24

# patch ndk
# https://github.com/android/ndk/issues/243
TOOLCHAIN_PATH=$(pwd)/toolchain
${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh \
    --install-dir=${TOOLCHAIN_PATH} \
    --verbose \
    --toolchain=${CV_STANDALONE_TOOLCHAIN_NAME} \
    --abis=${CV_ANDROID_PLATFORM} \
    --force
NDK_REL=$(grep -o '^Pkg\.Revision.*=[0-9]*.*' ${ANDROID_NDK}/source.properties 2>/dev/null | sed 's/[[:space:]]*//g' | cut -d "=" -f 2 | cut -d "." -f 1)

echo -e "${Green}ANDROID_NDK = ${ANDROID_NDK} version:${NDK_REL}${NC}"
echo -e "${Green}ANDROID_CMAKE = ${ANDROID_CMAKE}${NC}"
echo -e "${Green}ANDROID_ABI = ${ANDROID_ABI}${NC}"
echo -e "${Green}ANDROID_PLATFORM = ${ANDROID_PLATFORM}${NC}"

ABI_LIST=(${ANDROID_ABI//,/ })
for ABI in ${ABI_LIST[@]}; do
    echo -e "${Blue}--> ${ABI}...${NC}"

    BUILD_DIR=build-android-${ABI}
    mkdir -p ${BUILD_DIR}
    pushd ${BUILD_DIR}

    # Release: -O3 -DNDEBUG
    # Debug: -O0 -g
    # RelWithDebInfo: -O2 -g -DNDEBUG
    # MinSizeRel: -Os -DNDEBUG

    # cmake -G "Unix Makefiles" \
    #     -DCMAKE_INSTALL_PREFIX=install/${ABI} \
    #     -DCMAKE_BUILD_TYPE=Release \
    #     -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
    #     -DCMAKE_MAKE_PROGRAM="${ANDROID_NDK}/prebuilt/windows-x86_64/bin/make.exe" \
    #     -DANDROID_NDK=${ANDROID_NDK} \
    #     -DANDROID_ABI=${ABI} \
    #     -DANDROID_PLATFORM=android-${ANDROID_PLATFORM_API} \
    #     -DANDROID_ARM_NEON=ON \
    #     -DANDROID_STL=c++_shared \
    #     -DNCNN_VULKAN=${NCNN_VULKAN} ../../
    # cmake --build . --config Release --parallel 8
    # cmake --build . --config Release --target install

    popd
    echo -e "${Green}--> ${ABI} done ${NC}"
done
