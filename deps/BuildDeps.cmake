include(ExternalProject)

ExternalProject_Add(
  zlib
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/zlib
  GIT_REPOSITORY https://github.com/madler/zlib.git
  GIT_TAG v1.2.11
  GIT_PROGRESS 1
  CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  INSTALL_COMMAND make install
  UPDATE_COMMAND ""
  TEST_COMMAND ""
  BUILD_COMMAND "")

ExternalProject_Add(
  openssl
  DEPENDS zlib
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/openssl
  # GIT_REPOSITORY https://github.com/openssl/openssl.git
  # GIT_TAG OpenSSL_1_0_2u
  # GIT_PROGRESS 1
  URL https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz
  CONFIGURE_COMMAND ./config no-static shared --prefix=${CMAKE_INSTALL_PREFIX}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND make install
  UPDATE_COMMAND ""
  TEST_COMMAND ""
  BUILD_COMMAND make depend && make -j4)

ExternalProject_Add(
  curl
  DEPENDS zlib openssl
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/curl
  GIT_REPOSITORY https://github.com/curl/curl.git
  GIT_TAG curl-7_80_0
  GIT_PROGRESS 1
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
             -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
             -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
             -DCMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}
             -DBUILD_SHARED_LIBS=ON
             -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  INSTALL_COMMAND make -j4 install
  UPDATE_COMMAND ""
  TEST_COMMAND ""
  BUILD_COMMAND "")

ExternalProject_Add(
  aws-sdk
  DEPENDS curl
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/aws-sdk-cpp
  GIT_REPOSITORY https://github.com/aws/aws-sdk-cpp.git
  # GIT_TAG 1.9.234
  GIT_TAG 1.9.235
  GIT_PROGRESS 1
  GIT_SUBMODULES crt/aws-crt-cpp aws-cpp-sdk-core aws-cpp-sdk-cognito-identity
                 aws-cpp-sdk-kinesis aws-cpp-sdk-identity-management
  LIST_SEPARATOR "!"
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
             -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
             -DBUILD_ONLY=cognito-identity!kinesis!identity-management
             -DENABLE_TESTING=OFF
             -DCMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}
             -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DENABLE_UNITY_BUILD=OFF
  INSTALL_COMMAND make -j4 install
  # UPDATE_COMMAND ""
  UPDATE_DISCONNECTED ON
  TEST_COMMAND ""
  BUILD_COMMAND "")

