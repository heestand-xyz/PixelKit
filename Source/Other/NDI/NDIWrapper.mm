//
//  NDIWrapper.m
//  ndi test
//
//  Created by LeeJongMin on 2019/8/7.
//  Copyright © 2019 kyle wilson. All rights reserved.
//

#import "NDIWrapper.h"

#include "NDIMain.h"


@interface NDIWrapper() {
    NDIMain * m_wrapper;
    const NDIlib_v3* m_NDILib;
}

@end

@implementation NDIWrapper

- (int)initWrapper {
    m_wrapper = new NDIMain();
    return 0;
}
- (NSArray*) getNDISources {
    int count;
    NDIlib_source_t* sources = m_wrapper->getSources(&count);
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < count; i++) {
        NSString* string = [NSString stringWithCString:sources[i].p_ndi_name encoding:NSUTF8StringEncoding];
//        NSLog(string);
        [arr addObject: string];
    }
    for (int i = 0; i < count; i++) {
        NSString* string = [NSString stringWithCString:sources[i].p_url_address encoding:NSUTF8StringEncoding];
    }
    return arr;
}
- (Boolean) recordVideo:(NSString*) p_ndi_name file: (NSString*) p_file_name {
    m_wrapper->recordVideo([p_ndi_name cStringUsingEncoding:NSUTF8StringEncoding], [p_file_name cStringUsingEncoding:NSUTF8StringEncoding]);
    return true;
}
- (Boolean) stopRecord{
    return true;
}
- (Boolean) startCapture:(NSString*) p_ndi_name {
    m_wrapper->startCapture([p_ndi_name cStringUsingEncoding:NSUTF8StringEncoding]);
    return true;
}
- (Boolean) stopCapture{
    return true;
}

- (unsigned char*) getVideoFrame {
    int width, height, color, scanType;
    int64_t time;
    unsigned char* result = m_wrapper->getVideoFrame(&width, &height, &color, &time, &scanType);
    self->_width = width;
    self->_height = height;
    self->_color = color;
    self->_time = time;
    self->_scanType = scanType;
    return result;
}

//- (Boolean) sendPIXTexture {
//    unsigned char* result = m_wrapper->getVideoFrame(128, 128, 255, 0, 0);
//    return true;
//}

@end
