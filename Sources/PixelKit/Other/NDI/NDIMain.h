//
//  NDIMain.hpp
//  ndi test
//
//  Created by LeeJongMin on 2019/8/8.
//  Copyright © 2019 kyle wilson. All rights reserved.
//

#include <stdio.h>
#include <csignal>
#include <cstddef>
#include <cstdio>
#include <atomic>
#include <chrono>
#include <string>
#include <thread>

#include <stdlib.h>
#include <dlfcn.h>

#include <cstring>
#include "Processing.NDI.Lib.h"
static bool record_thread = false;

class CaptureThread
{
public:
//    bool record_thread;
    NDIlib_video_frame_v2_t p_video_buf;
    NDIlib_audio_frame_v2_t p_audio_buf;
    int width;
    int height;
    int fourCC;
    int size;
    int interlaced;
    unsigned char * p_video_buff;
    int64_t p_video_time;
    std::mutex mtx_lock;
    bool videoUpdated;
    bool audioUpdated;
    
    CaptureThread(const NDIlib_v3* p_NDILib, NDIlib_recv_instance_t* p_NDI_recv) {
        this->p_NDILib = p_NDILib;
        this->p_NDI_recv = p_NDI_recv;
        record_thread = true;
        p_video_buff = NULL;
        width = 0;
        height = 0;
        fourCC = 0;
        size = 0;
        videoUpdated = false;
        audioUpdated = false;
        interlaced = 0;
    }
    static int getBitsPerPixel(NDIlib_FourCC_type_e type) {
        switch(type) {
            case NDIlib_FourCC_type_RGBX:
            case NDIlib_FourCC_type_RGBA:
            case NDIlib_FourCC_type_BGRX:
            case NDIlib_FourCC_type_BGRA: return 32;
            case NDIlib_FourCC_type_UYVY: return 16;
            case NDIlib_FourCC_type_UYVA: return 16;
            case NDIlib_FourCC_type_YV12:
            case NDIlib_FourCC_type_NV12:
            case NDIlib_FourCC_type_I420: return 12;
        }
        return 32;
    }
    unsigned char* getVideoFrame() {
        if (!videoUpdated) {
            return NULL;
        }
        unsigned char* video_buff = new unsigned char[size];
        mtx_lock.lock();
        memcpy(video_buff, p_video_buff, size);
        mtx_lock.unlock();
        videoUpdated = false;
        return video_buff;
    }
    void capture() const {
        printf("CAAAAAAAPTURE! \n");
        
        while (record_thread) {
            NDIlib_video_frame_v2_t video_frame;
            NDIlib_audio_frame_v2_t audio_frame;
            printf("\\\n");
            printf("NDI FRAME > > > \n");
            
            NDIlib_frame_type_e type_captured = p_NDILib->recv_capture_v2(*p_NDI_recv, &video_frame, &audio_frame, NULL, 500); // NDIlib_recv_capture_v2
            CaptureThread* ptr = const_cast<CaptureThread*>(this);
            if (NDIlib_frame_type_audio == type_captured)
            {
//                p_audio_buf = audio_frame;
                p_NDILib->NDIlib_recv_free_audio_v2(*p_NDI_recv, &audio_frame);
                ptr->audioUpdated = true;
                printf("NDI AUDIO >->-> \n");
            }
            else if (NDIlib_frame_type_video == type_captured) {
                printf("NDI GOT FRAME >->-> \n");
                //video_frame.
                int size = video_frame.xres * getBitsPerPixel(video_frame.FourCC) / 8 * video_frame.xres / video_frame.picture_aspect_ratio; //video_frame.yres;
                if (p_video_buff == NULL) {
                    printf("NDI BAD A >->-> \n");
                    ptr->p_video_buff = new unsigned char[size];
                }
                else if (size != ptr->size) {
                    printf("NDI BAD B >->-> \n");
                    delete ptr->p_video_buff;
                    ptr->p_video_buff = new unsigned char[size];
                }
                printf("NDI GOOD >->-> \n");
                ptr->p_video_time = video_frame.timecode;
                ptr->size = size;
                ptr->width = video_frame.xres;
                ptr->height = video_frame.xres / video_frame.picture_aspect_ratio; //video_frame.yres;
                ptr->interlaced = video_frame.frame_format_type;
                ptr->fourCC = video_frame.FourCC;
                ptr->mtx_lock.lock();
                int lineBytes = video_frame.xres * getBitsPerPixel(video_frame.FourCC) / 8;
                if (ptr->interlaced == 1) {
                    memcpy(ptr->p_video_buff, video_frame.p_data, size);
                }
                else if (ptr->interlaced == 2) {
                    for (int i = 0; i < video_frame.yres; i++)
                        memcpy(ptr->p_video_buff + i * 2 * lineBytes, video_frame.p_data + i * lineBytes, lineBytes);
                }
                else {
                    for (int i = 0; i < video_frame.yres; i++)
                        memcpy(ptr->p_video_buff + (i*2 + 1) * lineBytes, video_frame.p_data+ i * lineBytes, lineBytes);
                }
                ptr->mtx_lock.unlock();
                ptr->videoUpdated = true;
                p_NDILib->NDIlib_recv_free_video_v2(*p_NDI_recv, &video_frame);
                
            }
            else{
                printf("NDI UNKNOWN >->-> \n");
                printf("NDI STATUS %d \n", type_captured);
//                printf("Timed out receiving audio from NDI source \n");
            }
            printf("/\n");
        }
        p_NDILib->NDIlib_recv_destroy(*p_NDI_recv);
    }
private:
    const NDIlib_v3* p_NDILib;
    NDIlib_recv_instance_t* p_NDI_recv;
};
class NDIMain
{
private:
    CaptureThread* m_captureThread;
    std::thread * t2;
    NDIlib_recv_instance_t pNDI_recv;
public:
    NDIMain();
    ~NDIMain();
    const NDIlib_v3* p_NDILib;
    int loadLibrary();
    NDIlib_source_t* getSources(int *count);
    const NDIlib_v3* initialize();
    int recordVideo(const char* p_ndi_name, const char* p_file_name);
    int stopVideo();
    int startCapture(const char* p_ndi_name);
    int stopCapture();
    unsigned char* getVideoFrame(int* width, int* height, int* color, int64_t* time, int* scanType) {
        if (m_captureThread == NULL)
            return NULL;
        *width = m_captureThread->width;
        *height = m_captureThread->height;
        *color = m_captureThread->fourCC;
        *time = m_captureThread->p_video_time;
        *scanType = m_captureThread->interlaced;
        return m_captureThread->getVideoFrame();
    }
};
