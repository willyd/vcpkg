if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "Caffe2 cannot be built for the x86 architecture")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO willyd/caffe
    REF 12c2320ead6399bc28bd589baa0d834ee94a3b83
    SHA512 bfee5a6a0a16f9131127d02ddce587092891a16750705c8f8a6211c598f98a14409ddb3bd7ff5f1d5a233f4b6a504121fcaf156a9e0d5398503ead5f09da941c
    HEAD_REF vcpkg
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DUSE_PREBUILT_DEPENDENCIES=OFF
    -DCOPY_PREREQUISITES=OFF
    -DINSTALL_PREREQUISITES=OFF
    # Set to ON to use python
    -DBUILD_python=OFF
    -DBUILD_python_layer=OFF
    -Dpython_version=3.6
    -DWITH_OPENCV=OFF
    -DBUILD_matlab=OFF
    -DBUILD_docs=OFF
    # Change to MKL to use MKL
    -DBLAS=Open
    -DCPU_ONLY=ON
    -DBUILD_TEST=OFF
    -DUSE_LEVELDB=OFF
    -DUSE_OPENCV=ON
    -DUSE_LMDB=ON
    -DUSE_NCCL=OFF
)

vcpkg_install_cmake()

# Move bin to tools
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(GLOB BINARIES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
foreach(binary ${BINARIES})
    get_filename_component(binary_name ${binary} NAME)
    file(RENAME ${binary} ${CURRENT_PACKAGES_DIR}/tools/${binary_name})
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/python)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/python)

file(GLOB DEBUG_BINARIES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${DEBUG_BINARIES})

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/caffe/CaffeTargets-debug.cmake CAFFE_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" CAFFE_DEBUG_MODULE "${CAFFE_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/caffe/CaffeTargets-debug.cmake "${CAFFE_DEBUG_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/caffe RENAME copyright)

vcpkg_copy_pdbs()
