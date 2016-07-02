#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
extern "C" {
	__declspec(dllexport) void TRLTAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	__declspec(dllexport) void TRLTAExtFinizer(void* extData);
}
#else
#include <stdio.h>
#include <Adobe AIR/Adobe AIR.h>

#define EXPORT __attribute__((visibility("default")))
extern "C" {
	EXPORT
		void TRLTAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);

	EXPORT
		void TRLTAExtFinizer(void* extData);
}
#endif