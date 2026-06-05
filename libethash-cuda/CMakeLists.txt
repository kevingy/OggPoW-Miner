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

find_package(CUDAToolkit REQUIRED)

set(ETHASH_CUDA_ARCHITECTURES)
if(COMPUTE AND (COMPUTE GREATER 0))
    list(APPEND ETHASH_CUDA_ARCHITECTURES ${COMPUTE})
else()
    if(NOT CUDAToolkit_VERSION VERSION_LESS 10.0)
        list(APPEND ETHASH_CUDA_ARCHITECTURES 75)
    endif()

    if(NOT CUDAToolkit_VERSION VERSION_LESS 11.1)
        list(APPEND ETHASH_CUDA_ARCHITECTURES 80 86)
    endif()

    if(NOT CUDAToolkit_VERSION VERSION_LESS 11.8)
        list(APPEND ETHASH_CUDA_ARCHITECTURES 89)
    endif()

    if(NOT CUDAToolkit_VERSION VERSION_LESS 12.0)
        list(APPEND ETHASH_CUDA_ARCHITECTURES 90)
    endif()

    # NVIDIA Blackwell / RTX 50 series
    # Requires CUDA Toolkit 12.8+.
    # RTX 5090 / 5080 / 5070 Ti / 5070 / 5060 Ti / 5060 / 5050 = compute capability 12.0.
    if(NOT CUDAToolkit_VERSION VERSION_LESS 12.8)
        list(APPEND ETHASH_CUDA_ARCHITECTURES 120-real 120-virtual)
    endif()
endif()

if(NOT ETHASH_CUDA_ARCHITECTURES)
    message(FATAL_ERROR "No supported CUDA architectures were selected for toolkit version ${CUDAToolkit_VERSION}")
endif()

file(GLOB sources CUDAMiner.cpp CUDAMiner_cuda.cu nvstub.c)
file(GLOB headers CUDAMiner.h CUDAMiner_cuda.h nvstub.h ${CMAKE_CURRENT_BINARY_DIR}/CUDAMiner_kernel.h)

add_library(ethash-cuda STATIC ${sources} ${headers})
set_target_properties(ethash-cuda PROPERTIES CUDA_ARCHITECTURES "${ETHASH_CUDA_ARCHITECTURES}")
add_dependencies(ethash-cuda cuda_kernel)

target_compile_options(ethash-cuda PRIVATE
    $<$<COMPILE_LANGUAGE:CUDA>:--ptxas-options=-v;-lineinfo;-use_fast_math>
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Release>>:-O3>
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Debug>>:-G>
)

if (NOT MSVC)
    target_compile_options(ethash-cuda PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:--disable-warnings>)
endif()

target_link_libraries(ethash-cuda ethcore ethash::ethash progpow Boost::thread)
target_link_libraries(ethash-cuda CUDA::nvrtc CUDA::cuda_driver)
target_include_directories(ethash-cuda PUBLIC ${CUDAToolkit_INCLUDE_DIRS})
target_include_directories(ethash-cuda PRIVATE .. ${CMAKE_CURRENT_BINARY_DIR})
