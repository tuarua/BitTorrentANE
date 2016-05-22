#ifndef __BitTorrentANE__BitTorrentANE__
#define __BitTorrentANE__BitTorrentANE__

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


