#pragma once

//***********************************************************************************************************************************************
// 
// Copyright(c) 2014-2018 NewTek, inc
// 
// This file is part of the Embedded SDK and may not be distributed.

#include "Processing.NDI.Lib.h"

// Additional values for the NDIlib_FourCC_type_e type
enum
{	// SpeedHQ formats at the highest bandwidth
	NDIlib_FourCC_type_SHQ0_highest_bandwidth = NDI_LIB_FOURCC('S', 'H', 'Q', '0'), // SpeedHQ 4:2:0
	NDIlib_FourCC_type_SHQ2_highest_bandwidth = NDI_LIB_FOURCC('S', 'H', 'Q', '2'), // SpeedHQ 4:2:2
	NDIlib_FourCC_type_SHQ7_highest_bandwidth = NDI_LIB_FOURCC('S', 'H', 'Q', '7'), // SpeedHQ 4:2:2:4

	// SpeedHQ formats at the lowest bandwidth
	NDIlib_FourCC_type_SHQ0_lowest_bandwidth = NDI_LIB_FOURCC('s', 'h', 'q', '0'), // SpeedHQ 4:2:0
	NDIlib_FourCC_type_SHQ2_lowest_bandwidth = NDI_LIB_FOURCC('s', 'h', 'q', '2'), // SpeedHQ 4:2:2
	NDIlib_FourCC_type_SHQ7_lowest_bandwidth = NDI_LIB_FOURCC('s', 'h', 'q', '7')  // SpeedHQ 4:2:2:4
};

// Additional values for NDIlib_recv_color_format_e type
enum
{	// Request that compressed video data is the desired format
	NDIlib_recv_color_format_compressed = 300
};

// This function will get the target frame size for this video. The video_frame structure does not need a valid data pointer
// but the rest of it is used to estimate the target frame size in bytes which you may use to estimate the current Q value.
PROCESSINGNDILIB_API
int NDIlib_send_get_target_frame_size(NDIlib_send_instance_t p_instance, const NDIlib_video_frame_v2_t* p_video_data);

// Create a new finder instance. This will return NULL if it fails.
// This function is deprecated, please use NDIlib_find_create_v2 if you can. This function
// ignores the p_extra_ips member and sets it to the default.
PROCESSINGNDILIB_API
NDIlib_find_instance_t NDIlib_find_create_v3(const NDIlib_find_create_t* p_create_settings NDILIB_CPP_DEFAULT_VALUE(NULL), const char* p_config_data NDILIB_CPP_DEFAULT_VALUE(NULL));

// Create a new receiver instance. This will return NULL if it fails. If you create this with the default settings (NULL)
// then it will automatically determine a receiver name.
PROCESSINGNDILIB_API
NDIlib_recv_instance_t NDIlib_recv_create_v4(const NDIlib_recv_create_v3_t* p_create_settings NDILIB_CPP_DEFAULT_VALUE(NULL), const char* p_config_data NDILIB_CPP_DEFAULT_VALUE(NULL));

// Create a new sender instance. This will return NULL if it fails. If you specify leave p_create_settings null then 
// the sender will be created with default settings. 
PROCESSINGNDILIB_API
NDIlib_send_instance_t NDIlib_send_create_v2(const NDIlib_send_create_t* p_create_settings NDILIB_CPP_DEFAULT_VALUE(NULL), const char* p_config_data NDILIB_CPP_DEFAULT_VALUE(NULL));
