if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "Caffe cannot be built for the x86 architecture")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO willyd/caffe
    REF cdf0f3185d076a894410720a2d806c250daca7a6
    SHA512 42d0a1c3b837adad8504227fa4ba16bca19dcadf540c87b3b106f48825137d8cac8a4abc9bba7e450a2870d8b45b5d6098a41dbb31555fc4847fdf608cc41eef
    HEAD_REF vcpkg
)

if("cuda" IN_LIST FEATURES)
    set(CPU_ONLY OFF)
else()
    set(CPU_ONLY ON)
endif()

if("mkl" IN_LIST FEATURES)
    set(BLAS MKL)
    set(ProgramFilesx86 "ProgramFiles(x86)")
    set(INTEL_ROOT $ENV{${ProgramFilesx86}}/IntelSWTools/compilers_and_libraries/windows)
    if(NOT EXISTS ${INTEL_ROOT})
        message(FATAL_ERROR "Could not find MKL. Build caffe without the mkl feature or install MKL.")
    endif()
else()
    set(BLAS Open)
endif()

if("opencv" IN_LIST FEATURES)
    set(USE_OPENCV ON)
else()
    set(USE_OPENCV OFF)
endif()

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
    -DBUILD_matlab=OFF
    -DBUILD_docs=OFF
    -DBLAS=${BLAS}
    -DCPU_ONLY=${CPU_ONLY}
    -DBUILD_TEST=OFF
    -DUSE_LEVELDB=OFF
    -DUSE_OPENCV=${USE_OPENCV}
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
