#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#else
#define __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES 0
#define BOOST_ASIO_SEPARATE_COMPILATION 0
#include <Adobe AIR/Adobe AIR.h>
#endif

extern "C" {
	__declspec(dllexport) void TRLTAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	__declspec(dllexport) void TRLTAExtFinizer(void* extData);
}