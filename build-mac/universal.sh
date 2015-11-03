#!/bin/sh
set -e

DEP_TARGET="static mailcore2 ios"
DEP_TARGET_OUTPUT="libMailCore-ios.a"
DEP_TARGET_INCLUDE="include"
ADDITION_OUTPUTS=("libsasl2.a" "libctemplate-ios.a" "libtidy.a" "libetpan-ios.a" "sasl2/libanonymous.a" "sasl2/libcrammd5.a" "sasl2/liblogin.a" "sasl2/libplain.a" "sasl2/libsasldb.a")
IPHONEOS_OUTPUTFOLDER="${BUILD_DIR}/${CONFIGURATION}-iphoneos"
SIMULATOR_OUTPUTFOLDER="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator"
UNIVERSAL_OUTPUTFOLDER="${BUILD_DIR}/${CONFIGURATION}-universal"

# Build for iphoneos & iphonesimulator
xcodebuild -project "${PROJECT_NAME}.xcodeproj" -target "${DEP_TARGET}" -configuration "${CONFIGURATION}" -sdk iphoneos ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
xcodebuild -project "${PROJECT_NAME}.xcodeproj" -target "${DEP_TARGET}" -configuration "${CONFIGURATION}" -sdk iphonesimulator ARCHS="i386 x86_64" VALID_ARCHS="arm64 armv7 armv7s i386 x86_64" BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

# Create fat library
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${DEP_TARGET_OUTPUT}.tmp.a" "${IPHONEOS_OUTPUTFOLDER}/${DEP_TARGET_OUTPUT}" "${SIMULATOR_OUTPUTFOLDER}/${DEP_TARGET_OUTPUT}"

# Combine all libraries
ALL_OUTPUTS="$(printf "${IPHONEOS_OUTPUTFOLDER}/%s " ${ADDITION_OUTPUTS[@]})${UNIVERSAL_OUTPUTFOLDER}/${DEP_TARGET_OUTPUT}.tmp.a"
./combine.sh ${ALL_OUTPUTS} "${UNIVERSAL_OUTPUTFOLDER}/${DEP_TARGET_OUTPUT}"
rm "${UNIVERSAL_OUTPUTFOLDER}/${DEP_TARGET_OUTPUT}.tmp.a"

# Copy include files
cp -R "${IPHONEOS_OUTPUTFOLDER}/${DEP_TARGET_INCLUDE}" "${UNIVERSAL_OUTPUTFOLDER}/"
