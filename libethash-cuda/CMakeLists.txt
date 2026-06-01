# A custom command and target to turn the CUDA kernel into a byte array header
# The normal build depends on it properly and if the kernel file is changed, then
# a rebuild of libethash-cuda should be triggered

add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h
	COMMAND ${CMAKE_COMMAND} ARGS
	-DTXT2STR_SOURCE_FILE="${CMAKE_CURRENT_SOURCE_DIR}/CUDAMiner_kernel.cu"
	-DTXT2STR_VARIABLE_NAME=CUDAMiner_kernel
	-DTXT2STR_HEADER_FILE="${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h"
	-P "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/txt2str.cmake"
	COMMENT "Generating CUDA Kernel"
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CUDAMiner_kernel.cu
)
add_custom_target(cuda_kernel DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h ${CMAKE_CURRENT_SOURCE_DIR}/CUDAMiner_kernel.cu)

find_package(CUDA REQUIRED)

if(MSVC)
    set(CUDA_USE_STATIC_CUDA_RUNTIME OFF)
    list(APPEND CUDA_NVCC_FLAGS "-Xcompiler=/MD")
endif()

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--ptxas-options=-v;-lineinfo;-use_fast_math)

if (NOT MSVC)
	list(APPEND CUDA_NVCC_FLAGS "--disable-warnings")
endif()

list(APPEND CUDA_NVCC_FLAGS_RELEASE -O3)
list(APPEND CUDA_NVCC_FLAGS_DEBUG -G)

if(COMPUTE AND (COMPUTE GREATER 0))
    list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_${COMPUTE},code=sm_${COMPUTE}")
else()
    if(NOT CUDA_VERSION VERSION_LESS 10.0)
        list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_75,code=sm_75")
    endif()

    if(NOT CUDA_VERSION VERSION_LESS 11.1)
        list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_80,code=sm_80")
        list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_86,code=sm_86")
    endif()

    if(NOT CUDA_VERSION VERSION_LESS 11.8)
        list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_89,code=sm_89")
    endif()

        if(NOT CUDA_VERSION VERSION_LESS 12.0)
        list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_90,code=sm_90")
    endif()

    # NVIDIA Blackwell / RTX 50 series
    # Requires CUDA Toolkit 12.8+.
    # RTX 5090 / 5080 / 5070 Ti / 5070 / 5060 Ti / 5060 / 5050 = compute capability 12.0.
    if(NOT CUDA_VERSION VERSION_LESS 12.8)
        list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_120,code=sm_120")

        # PTX fallback for future GPUs. This may help future architectures JIT,
        # but true RTX 60 support depends on future CUDA/toolkit support.
        list(APPEND CUDA_NVCC_FLAGS "-gencode arch=compute_120,code=compute_120")
    endif()
endif()

file(GLOB sources CUDAMiner.cpp CUDAMiner_cuda.cu nvstub.c)
file(GLOB headers CUDAMiner.h CUDAMiner_cuda.h nvstub.h ${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h)

cuda_add_library(ethash-cuda STATIC ${sources} ${headers})
add_dependencies(ethash-cuda cuda_kernel)
# Cmake doesn't handle nvrtc automatically
find_library(CUDA_nvrtc_LIBRARY NAMES nvrtc PATHS ${CUDA_TOOLKIT_ROOT_DIR} PATH_SUFFIXES lib64 lib/x64 lib64/stubs lib/x64/stubs lib NO_DEFAULT_PATH)
find_library(CUDA_cuda_LIBRARY NAMES cuda PATHS ${CUDA_TOOLKIT_ROOT_DIR} PATH_SUFFIXES lib64 lib/x64 lib64/stubs lib/x64/stubs lib NO_DEFAULT_PATH)
target_link_libraries(ethash-cuda ethcore ethash::ethash progpow Boost::thread)
target_link_libraries(ethash-cuda ${CUDA_nvrtc_LIBRARY} ${CUDA_cuda_LIBRARY})
target_include_directories(ethash-cuda PUBLIC ${CUDA_INCLUDE_DIRS})
target_include_directories(ethash-cuda PRIVATE .. ${CMAKE_CURRENT_BINARY_DIR})
