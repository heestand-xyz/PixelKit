//
//  NDIMain.cpp
//  ndi test
//
//  Created by LeeJongMin on 2019/8/8.
//  Copyright © 2019 kyle wilson. All rights reserved.
//

#include "NDIMain.h"
#include <csignal>
#include <cstddef>
#include <cstdio>
#include <atomic>
#include <chrono>
#include <string>
#include <thread>

#include <stdlib.h>
#include <dlfcn.h>

#include "Processing.NDI.Lib.h"

static std::atomic<bool> exit_loop(false);
static void sigint_handler(int)
{    exit_loop = true;
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Struct defining playback state
#define NUM_BUFFERS 3



///////////////////////////////////////////////////////////////////////////////////////////////

NDIMain::NDIMain() {
    p_NDILib = initialize();
}
NDIMain::~NDIMain() {
    
}
NDIlib_source_t* NDIMain::getSources(int *count) {
    
    // Lets get all of the DLL entry points
    //    const NDIlib_v3* p_NDILib = NDIlib_v3_load();
    //
    //    // We can now run as usual
    //    if (!p_NDILib->NDIlib_initialize())
    //    {    // Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
    //        // you can check this directly with a call to NDIlib_is_supported_CPU()
    //        printf("Cannot run NDI.");
    //        return NULL;
    //    }
    //
    //    // Catch interrupt so that we can shut down gracefully
    //    signal(SIGINT, sigint_handler);
    
    // We first need to look for a source on the network
    const NDIlib_find_create_t NDI_find_create_desc = { true, NULL };
    
    // Create a finder
    NDIlib_find_instance_t pNDI_find = p_NDILib->NDIlib_find_create_v2(&NDI_find_create_desc);
    if (!pNDI_find) return NULL;
    
    // We wait until there is at least one source on the network
    uint32_t no_sources = 0;
    const NDIlib_source_t* p_sources = NULL;
    while (!exit_loop && !no_sources)
    {    // Wait until the sources on the nwtork have changed
        p_NDILib->NDIlib_find_wait_for_sources(pNDI_find, 1000);
        p_sources = p_NDILib->NDIlib_find_get_current_sources(pNDI_find, &no_sources);
    }
    
    // We need at least one source
    if (!p_sources) return NULL;
    
    int srcCnt = 0;
    while (p_sources[srcCnt].p_ndi_name != NULL)
    {
        srcCnt++;
    }
    NDIlib_source_t* retSources = new NDIlib_source_t[srcCnt];
    for (int i = 0; i < srcCnt; i++){
        retSources[i] = p_sources[i];
    }
    *count = srcCnt;
    return retSources;
}
int NDIMain::stopVideo(){
    return 0;
}

int NDIMain::startCapture(const char* p_ndi_name){
    if (record_thread) {
        record_thread = false;
        
        t2->join();
//        sleep(500);
    }
    record_thread = true;
    
    NDIlib_source_t ndi_source = { 0 };
    ndi_source.p_ip_address = "";
    ndi_source.p_ndi_name = p_ndi_name;
    NDIlib_recv_create_v3_t NDI_recv_create_desc = { ndi_source, NDIlib_recv_color_format_fastest, NDIlib_recv_bandwidth_highest, /* Allow fielded video */true, p_ndi_name}; //"Video/Audio Receiver"
    pNDI_recv = p_NDILib->NDIlib_recv_create_v3(&NDI_recv_create_desc);
    if (!pNDI_recv)
    {
        return -1;
    }
    m_captureThread = new CaptureThread(p_NDILib, & pNDI_recv);
    t2 = new std::thread{&CaptureThread::capture, m_captureThread};
//    std::thread t1{&CaptureThread::capture, m_captureThread};
//    t1.join();
    //std::thread(captureThread2, 1);
    return 0;
}

int NDIMain::stopCapture(){
    record_thread = false;
    t2->join();
    return 0;
}
int NDIMain::recordVideo(const char* p_ndi_name, const char* p_file_name) {
    
    // ToDo
    
    NDIlib_source_t ndi_source = { 0 };
    ndi_source.p_ip_address = "";
    ndi_source.p_ndi_name = p_ndi_name;
    
    
    // We now have at least one source, so we create a receiver to look at it.
    // We tell it that we prefer YCbCr video since it is more efficient for us. If the source has an alpha channel
    // it will still be provided in BGRA
    //    NDIlib_recv_create_v3_t NDI_recv_create_desc = { p_sources[0], NDIlib_recv_color_format_fastest, NDIlib_recv_bandwidth_audio_only, /* Allow fielded video */true, "Audio Play Example Receiver" };
    NDIlib_recv_create_v3_t NDI_recv_create_desc = { ndi_source, NDIlib_recv_color_format_fastest, NDIlib_recv_bandwidth_highest, /* Allow fielded video */true, "Audio Play Example Receiver" };
    
    // Create the receiver
    NDIlib_recv_instance_t pNDI_recv = p_NDILib->NDIlib_recv_create_v3(NULL);//&NDI_recv_create_desc);
    if (!pNDI_recv)
    {
        //        p_NDILib->NDIlib_find_destroy(pNDI_find);
        return 0;
    }
    p_NDILib->NDIlib_recv_connect(pNDI_recv, &ndi_source);
    
    
    // Try for one minute to get audio
    const auto start = std::chrono::high_resolution_clock::now();
    while (!exit_loop && std::chrono::high_resolution_clock::now() - start < std::chrono::minutes(1))
    {
        // The descriptors
        
        NDIlib_video_frame_v2_t video_frame;
        NDIlib_audio_frame_v2_t audio_frame;
        
        NDIlib_frame_type_e type_captured = p_NDILib->NDIlib_recv_capture_v2(pNDI_recv, &video_frame, &audio_frame, NULL, 1500);
        if (NDIlib_frame_type_audio == type_captured)
        {
            p_NDILib->NDIlib_recv_free_audio_v2(pNDI_recv, &audio_frame);
            break;
        }
        else if (NDIlib_frame_type_video == type_captured) {
            p_NDILib->NDIlib_recv_free_video_v2(pNDI_recv, &video_frame);
            printf("Video \n");
        }
        else{
            printf("Timed out receiving audio from NDI source \n");
        }
    }
    
    
    // Destroy the receiver
    printf("Destroying the NDI receiver \n");
    p_NDILib->NDIlib_recv_destroy(pNDI_recv);
    printf("The NDI receiver has been destroyed \n");
    
    // Not required, but nice
    p_NDILib->NDIlib_destroy();
    
    
    return 0;
}



const NDIlib_v3* NDIMain::initialize() {
    const NDIlib_v3* p_NDILib = NDIlib_v3_load();
    
    // We can now run as usual
    if (!p_NDILib->NDIlib_initialize())
    {    // Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
        // you can check this directly with a call to NDIlib_is_supported_CPU()
        printf("Cannot run NDI.");
        return NULL;
    }
    
    // Catch interrupt so that we can shut down gracefully
    signal(SIGINT, sigint_handler);
    return p_NDILib;
}
int NDIMain::loadLibrary() {
    
    
    // Lets get all of the DLL entry points
    const NDIlib_v3* p_NDILib = NDIlib_v3_load();
    
    // We can now run as usual
    if (!p_NDILib->NDIlib_initialize())
    {    // Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
        // you can check this directly with a call to NDIlib_is_supported_CPU()
        printf("Cannot run NDI.");
        return 0;
    }
    
    // Catch interrupt so that we can shut down gracefully
    signal(SIGINT, sigint_handler);
    
    // We first need to look for a source on the network
    const NDIlib_find_create_t NDI_find_create_desc = { true, NULL };
    
    // Create a finder
    NDIlib_find_instance_t pNDI_find = p_NDILib->NDIlib_find_create_v2(&NDI_find_create_desc);
    if (!pNDI_find) return 0;
    
    // We wait until there is at least one source on the network
    uint32_t no_sources = 0;
    const NDIlib_source_t* p_sources = NULL;
    while (!exit_loop && !no_sources)
    {    // Wait until the sources on the nwtork have changed
        p_NDILib->NDIlib_find_wait_for_sources(pNDI_find, 1000);
        p_sources = p_NDILib->NDIlib_find_get_current_sources(pNDI_find, &no_sources);
    }
    
    // We need at least one source
    if (!p_sources) return 0;
    
    // ToDo
    /*
     NDIlib_source_t ndi_source = { 0 };
     ndi_source.p_ip_address = "";
     ndi_source.p_ndi_name = "NewTek (NewTek SDI)";
     */
    
    // We now have at least one source, so we create a receiver to look at it.
    // We tell it that we prefer YCbCr video since it is more efficient for us. If the source has an alpha channel
    // it will still be provided in BGRA
    NDIlib_recv_create_v3_t NDI_recv_create_desc = { p_sources[0], NDIlib_recv_color_format_fastest, NDIlib_recv_bandwidth_audio_only, /* Allow fielded video */true, "Audio Play Example Receiver" };
    
    // Create the receiver
    NDIlib_recv_instance_t pNDI_recv = p_NDILib->NDIlib_recv_create_v3(&NDI_recv_create_desc);
    if (!pNDI_recv)
    {    p_NDILib->NDIlib_find_destroy(pNDI_find);
        return 0;
    }
    //    p_NDILib->NDIlib_recv_connect(p_sources[0]);
    // Destroy the NDI finder. We needed to have access to the pointers to p_sources[0]
    p_NDILib->NDIlib_find_destroy(pNDI_find);
    
    
    // Try for one minute to get audio
    const auto start = std::chrono::high_resolution_clock::now();
    while (!exit_loop && std::chrono::high_resolution_clock::now() - start < std::chrono::minutes(1))
    {
        // The descriptors
        NDIlib_audio_frame_v2_t audio_frame;
        NDIlib_frame_type_e type_captured = p_NDILib->NDIlib_recv_capture_v2(pNDI_recv, NULL, &audio_frame, NULL, 1000);
        if (NDIlib_frame_type_audio == type_captured)
        {
            p_NDILib->NDIlib_recv_free_audio_v2(pNDI_recv, &audio_frame);
            break;
        }
        else
            printf("Timed out receiving audio from NDI source \n");
    }
    
    // Destroy the receiver
    printf("Destroying the NDI receiver \n");
    p_NDILib->NDIlib_recv_destroy(pNDI_recv);
    printf("The NDI receiver has been destroyed \n");
    
    // Not required, but nice
    p_NDILib->NDIlib_destroy();
    
    // Finished
    return 0;
}
