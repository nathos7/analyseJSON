cmake_minimum_required(VERSION 3.0)

project(analyseJSON)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

BISON_TARGET(AJ src/analyseJSON_yacc.y src/analyseJSON_yacc.c)
FLEX_TARGET(AJ src/analyseJSON_lex.l src/lex.yy.c)

add_executable(analyseJSON ${BISON_AJ_OUTPUTS})
target_include_directories(analyseJSON PRIVATE src)

install (TARGETS analyseJSON DESTINATION bin)

########################################## MANUALS ###########################

FIND_PROGRAM(GZIP_TOOL
             NAMES gzip
             PATHS /bin
                   /usr/bin
                   /usr/local/bin)

IF(NOT GZIP_TOOL)
  MESSAGE(FATAL_ERROR "Unable to find 'gzip' program") 
ENDIF(NOT GZIP_TOOL)


# Compression of the manuals
ADD_CUSTOM_COMMAND(OUTPUT analyseJSON.1.gz
	COMMAND ${GZIP_TOOL} -c ${CMAKE_CURRENT_SOURCE_DIR}/analyseJSON.1 > ${CMAKE_CURRENT_BINARY_DIR}/analyseJSON.1.gz
                   DEPENDS analyseJSON.1
                   COMMENT "Building analyseJSON.1.gz")
#force compression
add_custom_target(run ALL
    DEPENDS analyseJSON.1.gz)



# Installation of the manuals
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/analyseJSON.1.gz
        DESTINATION "share/man/man1"
        PERMISSIONS OWNER_READ GROUP_READ WORLD_READ RENAME analyseJSON.1.gz)
#################################################################################


INCLUDE(InstallRequiredSystemLibraries)

INCLUDE("packaging/CMakePackages.txt")