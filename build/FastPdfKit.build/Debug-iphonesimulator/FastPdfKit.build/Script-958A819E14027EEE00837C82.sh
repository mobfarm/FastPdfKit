#!/bin/sh
set -e

set +u
if [[ $UFW_MASTER_SCRIPT_RUNNING ]]
then
# Nothing for the slave script to do
exit 0
fi
set -u
export UFW_MASTER_SCRIPT_RUNNING=1


# Functions

## List files in the specified directory, storing to the specified array.
#
# @param $1 The path to list
# @param $2 The name of the array to fill
#
##
list_files ()
{
    filelist=$(ls "$1")
    while read line
    do
    eval "$2[\${#$2[*]}]=\"\$line\""
    done <<< "$filelist"
}


# Sanity check

if [[ ! -f "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" ]]
then
echo "Framework target \"${TARGET_NAME}\" had no source files to build from. Make sure your source files have the correct target membership"
exit 1
fi


# Gather information

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
echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
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


# Short-circuit if all binaries are up to date.
# We already checked the other platform in the prerun script.

if [[ -f "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" ]] && [[ -f "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]] && [[ ! "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" -nt "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/${EXECUTABLE_PATH}" ]]
then
exit 0
fi


# Make sure the other platform gets built

echo "Build other platform"

echo xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${UFW_OTHER_PLATFORM}${UFW_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" CONFIGURATION_TEMP_DIR="${PROJECT_TEMP_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}" $ACTION
xcodebuild -project "${PROJECT_FILE_PATH}" -target "${TARGET_NAME}" -configuration "${CONFIGURATION}" -sdk ${UFW_OTHER_PLATFORM}${UFW_SDK_VERSION} BUILD_DIR="${BUILD_DIR}" CONFIGURATION_TEMP_DIR="${PROJECT_TEMP_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}" $ACTION


# Build the fat static library binary

echo "Create universal static library"

echo "$PLATFORM_DEVELOPER_BIN_DIR/libtool" -static "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" -o "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}.temp"
"$PLATFORM_DEVELOPER_BIN_DIR/libtool" -static "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" "${UFW_OTHER_BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}" -o "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}.temp"

echo mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}.temp" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}"
mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}.temp" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}"


# Build framework structure

echo "Build symlinks"

echo ln -sf A "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Versions/Current"
ln -sf A "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Versions/Current"
echo ln -sf Versions/Current/Headers "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Headers"
ln -sf Versions/Current/Headers "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Headers"
echo ln -sf Versions/Current/Resources "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Resources"
ln -sf Versions/Current/Resources "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Resources"
echo ln -sf "Versions/Current/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${EXECUTABLE_NAME}"
ln -sf "Versions/Current/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${EXECUTABLE_NAME}"


# Link to binary for unit tests

mkdir -p "${BUILT_PRODUCTS_DIR}/.fake_fw_testing.framework"
ln -sf "../${WRAPPER_NAME}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/.fake_fw_testing.framework/.fake_fw_testing"


# Build embedded framework structure

echo "Build Embedded Framework"

echo rm -rf "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework"
rm -rf "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework"
echo mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/Resources"
mkdir -p "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/Resources"
echo cp -a "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/"
cp -a "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/"

declare -a UFW_FILE_LIST
list_files "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" UFW_FILE_LIST
for filename in "${UFW_FILE_LIST[@]}"
do
if [[ "${filename}" != "Info.plist" ]] && [[ ! "${filename}" =~ .*\.lproj$ ]]
then
echo ln -sf "../${WRAPPER_NAME}/Resources/${filename}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/Resources/${filename}"
ln -sf "../${WRAPPER_NAME}/Resources/${filename}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.embeddedframework/Resources/${filename}"
fi
done


# Replace other platform's framework with a copy of this one (so that both have the same universal binary)

echo "Copy from $UFW_SDK_PLATFORM to $UFW_OTHER_PLATFORM"

echo rm -rf "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"
rm -rf "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"
echo cp -a "${BUILD_DIR}/${CONFIGURATION}-${UFW_SDK_PLATFORM}" "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"
cp -a "${BUILD_DIR}/${CONFIGURATION}-${UFW_SDK_PLATFORM}" "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}"

echo "Copying the Framework to the project directory"
rm -rf "${PROJECT_DIR}/${PRODUCT_NAME}.embeddedframework"
cp -a "${BUILD_DIR}/${CONFIGURATION}-${UFW_OTHER_PLATFORM}/${PRODUCT_NAME}.embeddedframework" "${PROJECT_DIR}/"

# echo /Developer/Tools/Rez -append "${PROJECT_DIR}/Resources/tempicns.rsrc" -o "$'${PROJECT_DIR}/${PRODUCT_NAME}.embeddedframework/Icon\r'"
# /Developer/Tools/Rez -append "${PROJECT_DIR}/Resources/tempicns.rsrc" -o "${PROJECT_DIR}/${PRODUCT_NAME}.embeddedframework/Icon\r"
# /Developer/Tools/SetFile -a C "${PROJECT_DIR}/${PRODUCT_NAME}.embeddedframework"
