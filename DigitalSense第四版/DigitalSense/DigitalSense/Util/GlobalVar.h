//
//  GlobalVar.h
//  FruitCut
//
//  Created by baolicheng on 16/5/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#ifndef GlobalVar_h
#define GlobalVar_h
#define APPID_VALUE @"57328e58"
#define TIMEOUT_VALUE  @"2000" // 语音timeout连接超时的时间，以ms为单位

/*********************API接口****************************/
/**
 *  上传开关机时间API
 */
//////////////////////////////////////////////////////////
#define SC_UploadOpenAndCloseDeviceTime_API @"/app/v1/smell-device/:hid"
/////////////////////////////////////////////////////////

/**
 *  请求气味信息API
 */
//////////////////////////////////////////////////////////
#define SC_FruitInfo_API @"/app/v1/smell-bottle/amount?type=ios&new=1"
/////////////////////////////////////////////////////////

/**
 *  请求皮肤列表API
 */
//////////////////////////////////////////////////////////
#define SC_SmellSkin_API @"/app/v1/smell-skin"
/////////////////////////////////////////////////////////

/**
 *  请求皮肤包API
 */
//////////////////////////////////////////////////////////
#define SC_SmellSkinPacket_API @"/app/v1/smell-skin/:id"
/////////////////////////////////////////////////////////
/*********************API接口****************************/

/**
 *  请求脚本API
 */
//////////////////////////////////////////////////////////+
#define SC_Script_API @"/app/v1/schedule-device/:sn"
/////////////////////////////////////////////////////////
/*********************API接口****************************/
#endif /* GlobalVar_h */
