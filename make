#!/usr/bin/ bash
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
echo "Cloniing AnyKernel"
git clone --quiet -j32 https://github.com/WEEDRR/AnyKernel3 -b neesan dapur
echo "Done"
TANGGAL=$(date +'%H%M-%d%m%y')
START=$(date +"%s")
GCC="/root/tools/11/bin/aarch64-elf-"
GCC32="/root/tools/arm11/bin/arm-eabi-"
export ARCH=arm64
export KBUILD_BUILD_USER=Zulf
export KBUILD_BUILD_HOST=NusantaraDevs
# Push kernel to channel
function push() {
    cd dapur || exit 1
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Asus Max Pro M1 (X00TD) Android 9.0/10 non Sar</b> | <b>$(clang --version | head -n 1 | perl -pe 's/\(https.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
function cleaner() {
    echo "Cleaning..."
    rm -rf *.zip Image.gz-dtb
    cd .. || exit 1
    rm -rf out
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Bjirr Error :v"
    exit 1
}
function info() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "parse_mode=markdown" \
        -d text="ProjectThanksYou new build!%0AFor device X00TD (Asus Max Pro M1)%0AAt branch eas-test"
}
# Compile plox
function compile() {
	make -s -C $(pwd) -j8 O=out X00TD_defconfig
	make -C $(pwd) CROSS_COMPILE="${GCC}" CROSS_COMPILE_ARM32="${GCC32}" O=out -j8
    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb dapur/
}
# Zipping
function zipping() {
    cd dapur || exit 1
    if [ "$is_test" = true ]; then
        zip -r9 neesan-Test-"${TANGGAL}".zip * -x LICENCE README.md
    else
        zip -r9 neesan-"${TANGGAL}".zip * -x LICENCE README.md
    fi #ngentod
    cd .. #well
}
info
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
cleaner
