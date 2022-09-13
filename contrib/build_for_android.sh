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
# support abi list on windows x64: armeabi-v7a,arm64-v8a,x86_64
ANDROID_ABI="armeabi-v7a,arm64-v8a,x86_64"

NCNN_VULKAN=OFF
ANDROID_PLATFORM=android-21

# If you want to enable Vulkan, platform api version >= android-24 is needed
# NCNN_VULKAN=ON
# ANDROID_PLATFORM=android-24

echo -e "${Green}ANDROID_NDK = ${ANDROID_NDK}${NC}"
echo -e "${Green}ANDROID_CMAKE = ${ANDROID_CMAKE}${NC}"
echo -e "${Green}ANDROID_ABI = ${ANDROID_ABI}${NC}"
echo -e "${Green}ANDROID_PLATFORM = ${ANDROID_PLATFORM}${NC}"

ABI_LIST=(${ANDROID_ABI//,/ })
for ABI in ${ABI_LIST[@]}; do
    echo -e "${Blue}--> ${ABI}...${NC}"
    cmake -G "Unix Makefiles" \
        -DCMAKE_INSTALL_PREFIX=$(pwd)/install/${ABI} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
        -DCMAKE_MAKE_PROGRAM="${ANDROID_NDK}/prebuilt/windows-x86_64/bin/make.exe" \
        -DANDROID_NDK=${ANDROID_NDK} \
        -DANDROID_ABI=${ABI} \
        -DANDROID_PLATFORM=${ANDROID_PLATFORM} \
        -DANDROID_ARM_NEON=ON \
        -DANDROID_STL=c++_shared \
        -DNCNN_VULKAN=${NCNN_VULKAN} ..
    cmake --build . --parallel 8
    cmake --build . --target install
    echo -e "${Green}--> ${ABI} done ${NC}"
done
