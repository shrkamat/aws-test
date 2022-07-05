
THIS_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# All below configurations are defaults for PC builds
# for (corss compilation)[README.md#crosscompile] these configs will need to be explicitly passed
#
# Sample usecases
# ===============
# 1. Cross-compiled deps staged to /opt/awssdk
# `OSS_DESTDIR=/opt/awssdk TOOLCHAIN_FILE=toolchains/arm64-toolchain.cmake make deps`
#
# 2. PC build awssdk to be installed to /opt/awssdk
# `OSS_PREFIX=/opt/awssdk make deps`
CMAKE              := cmake
MAKE               := make

# Where to build (leave defaults for cross compilation too)
BUILD_DIR          ?= $(THIS_DIR)/build

# Where to build deps (leave defaults for cross compilation too)
DEPS_BUILD_DIR     ?= $(THIS_DIR)/build/deps

# for cross compilation use prefix /SROOT
OSS_PREFIX         ?= $(DEPS_BUILD_DIR)/staging

# Debug, Release, RelWithDebInfo, MinSizeRel
CMAKE_BUILD_TYPE   ?= Debug

# for cross compilation only (see https://cmake.org/cmake/help/latest/envvar/DESTDIR.html)
OSS_DESTDIR        ?=

# internal vars
CMAKE_FLAGS        := -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)
MAKE_PRESETS       :=

# toolchain file for cross compilation
# IMPORTANT toolchain file must set CORSS_COMPILING=TRUE, this controls unit test to be enabled / disabled
ifneq ($(origin TOOLCHAIN_FILE),undefined)
  $(warning toolchain path is set to $(abspath $(TOOLCHAIN_FILE)))
  CMAKE_FLAGS += -DCMAKE_TOOLCHAIN_FILE=$(abspath $(TOOLCHAIN_FILE))
  ifeq ($(strip $(OSS_DESTDIR)), )
    OSS_DESTDIR := $(OSS_PREFIX)
  endif
  OSS_PREFIX  := /SROOT
endif

ifneq ($(strip $(OSS_DESTDIR)), )
  # OSS_DESTDIR is defined
  MAKE_PRESETS += DESTDIR=$(OSS_DESTDIR)
  $(warning DESTDIR is set to $(OSS_DESTDIR))
endif

# Path where third party dep builds have to installed (make deps)
OSS_STAGING_DIR    := $(OSS_DESTDIR)/$(OSS_PREFIX)

# exports
export LD_LIBRARY_PATH:=$(OSS_STAGING_DIR)/lib:${LD_LIBRARY_PATH}
export OSS_DESTDIR


all: $(BUILD_DIR)/CMakeCache.txt
	make -C build
	@echo "ClarissaClient-Linux SDK build is complete!"

$(BUILD_DIR)/CMakeCache.txt: CMakeLists.txt
	$(CMAKE) -B build -DCMAKE_FIND_ROOT_PATH=$(OSS_STAGING_DIR) $(CMAKE_FLAGS)

deps: $(DEPS_BUILD_DIR)/CMakeCache.txt
	$(MAKE_PRESETS) $(MAKE) -C $(DEPS_BUILD_DIR)
	@echo "deps build is complete"
	@echo "deps artifacts available @ $(OSS_STAGING_DIR)"

$(DEPS_BUILD_DIR)/CMakeCache.txt: deps/CMakeLists.txt
	$(CMAKE) -B $(DEPS_BUILD_DIR) -DCMAKE_INSTALL_PREFIX=$(OSS_PREFIX) -DCMAKE_FIND_ROOT_PATH=$(OSS_STAGING_DIR) $(CMAKE_FLAGS) -S deps

check: all
	echo "Run test here"
