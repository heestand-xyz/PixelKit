//
//  NDIWrapper.h
//  ndi test
//
//  Created by LeeJongMin on 2019/8/7.
//  Copyright © 2019 kyle wilson. All rights reserved.
//

#ifndef NDIWrapper_h
#define NDIWrapper_h


#import <Foundation/Foundation.h>

@interface NDIWrapper : NSObject
@property int width;
@property int height;
@property int color;
@property int64_t time;
@property int scanType;
- (int)initWrapper;
- (NSArray*) getNDISources;
- (Boolean) recordVideo:(NSString*) p_ndi_name file: (NSString*) p_file_name;
- (Boolean) stopRecord;
- (Boolean) startCapture:(NSString*) p_ndi_name;
- (Boolean) stopCapture;
- (unsigned char*) getVideoFrame;
//- (Boolean) sendPIXTexture;
@end
#endif /* NDIWrapper_h */
