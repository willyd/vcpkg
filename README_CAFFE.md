# Generating dependencies for Caffe

## Patch boost to build boost.python

See [link](https://github.com)

## Install dependencies

```Batch
vcpkg install boost gflags glog hdf5 lmdb protobuf opencv openblas --triplet x64-windows
```

## Patch hdf5-config

Replace lines 64-67 by:
```CMake
if (${HDF5_PACKAGE_NAME}_ENABLE_PARALLEL)
  set (${HDF5_PACKAGE_NAME}_MPI_C_INCLUDE_PATH "${PACKAGE_PREFIX_DIR}/include")
  set (${HDF5_PACKAGE_NAME}_MPI_C_LIBRARIES    "${PACKAGE_PREFIX_DIR}/lib/msmpi.lib")
endif ()
```

## Export

```
vcpkg export boost:x64-windows gflags:x64-windows glog:x64-windows hdf5:x64-windows lmdb:x64-windows protobuf:x64-windows opencv:x64-windows openblas:x64-windows --zip
```