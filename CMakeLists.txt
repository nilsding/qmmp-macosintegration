cmake_minimum_required(VERSION 3.14)

project(libmacosintegration LANGUAGES CXX OBJCXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_library(MEDIAPLAYER_FRAMEWORK NAMES MediaPlayer REQUIRED)
find_library(FOUNDATION_FRAMEWORK NAMES Foundation REQUIRED)

find_package(QT NAMES Qt5 COMPONENTS MacExtras Widgets Gui Core REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS MacExtras Widgets Gui Core REQUIRED)

find_package(PkgConfig REQUIRED)
pkg_check_modules(QmmpUi REQUIRED IMPORTED_TARGET qmmpui)
pkg_check_modules(Qmmp REQUIRED IMPORTED_TARGET qmmp)
pkg_get_variable(QMMP_PLUGIN_DIR qmmp plugindir)

add_library(macosintegration MODULE
  macosintegration.mm
  macosintegration.h
  macosintegrationfactory.cpp
  macosintegrationfactory.h
)

target_include_directories(macosintegration PUBLIC "${MEDIAPLAYER_FRAMEWORK}/Headers")

target_link_libraries(macosintegration PRIVATE
    Qt${QT_VERSION_MAJOR}::MacExtras
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Core
    PkgConfig::QmmpUi
    PkgConfig::Qmmp
    ${MEDIAPLAYER_FRAMEWORK}
    ${FOUNDATION_FRAMEWORK}
)

install(TARGETS macosintegration DESTINATION ${QMMP_PLUGIN_DIR}/General)
