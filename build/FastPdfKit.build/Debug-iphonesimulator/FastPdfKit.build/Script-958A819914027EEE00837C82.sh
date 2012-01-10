#!/bin/sh
set -e

set +u
if [[ $UFW_MASTER_SCRIPT_RUNNING ]]
then
# Nothing for the slave script to do
exit 0
fi
set -u

if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
UFW_SDK_PLATFORM=${BASH_REMATCH[1]}
else
echo "Could not find platform name from SDK_NAME: $SDK_NAME"
exit 1
fi

if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]
then
UFW_SDK_VERSION=${BASH_REMATCH[1]}
else
echo "Could not find sdk version  from SDK_NAME: $SDK_NAME"
exit 1
fi

if [[ "$UFW_SDK_PLATFORM" = "iphoneos" ]]
then
UFW_OTHER_PLATFORM=iphonesimulator
else
UFW_OTHER_PLATFORM=iphoneos
fi

if [[ "$BUILT_PRODUCTS_DIR" =~ (.*)$UFW_SDK_PLATFORM$ ]]
then
UFW_OTHER_BUILT_PRODUCTS_DIR="${BASH_REMATCH[1]}${UFW_OTHER_PLATFORM}"
else
echo "Could not find $UFW_SDK_PLATFORM in $BUILT_PRODUCTS_DIR"
exit 1
fi


# Short-circuit if all binaries are up to date

if [[ -f "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" ]] && \
[[ -f "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]] && \
[[ ! "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" -nt "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]]
[[ -f "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" ]] && \
[[ -f "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]] && \
[[ ! "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" -nt "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]]
then
exit 0
fi


# Clean other platform if needed

if [[ ! -f "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" ]]
then
echo "Platform \"$UFW_SDK_PLATFORM\" was cleaned recently. Cleaning \"$UFW_OTHER_PLATFORM\" as well"
echo xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${UFW_OTHER_PLATFORM}${UFW_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" CONFIGURATION_TEMP_DIR="${PROJECT_TEMP_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}" clean
xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${UFW_OTHER_PLATFORM}${UFW_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" CONFIGURATION_TEMP_DIR="${PROJECT_TEMP_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}" clean
fi


# Make sure we are building from fresh binaries

rm -rf "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}"
rm -rf "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework"
rm -rf "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}"
rm -rf "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework"

