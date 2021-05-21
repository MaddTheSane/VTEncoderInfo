//
//  main.swift
//  VideoToolboxSwift
//
//  Created by C.W. Betts on 5/21/21.
//  Copyright © 2021 8 Birds Video Inc. All rights reserved.
//

import Foundation
import VideoToolbox
import CoreMedia

private func printIndent(pad: Int) {
	guard pad != 0 else {
		return
	}
	var indentStr = ""
	let tabs = pad / 4
	let remainingSpaces = pad % 4
	if tabs > 0 {
		for _ in 0 ..< tabs {
			indentStr += "\t"
		}
	}
	
	if remainingSpaces > 0 {
		for _ in 0 ..< remainingSpaces {
			indentStr += " "
		}
	}
	
	print(indentStr, terminator: "")
}

private func printCFString(_ cfStr: CFString) {
	print(cfStr as String, terminator: "")
}

private func printStringProperty(name: String, value val: CFString, pad: Int) {
	printIndent(pad: pad)
	print("\(name): ", terminator: "")
	printCFString(val)
	print()
}

private func printStringProperty(name: String, value val: String?, pad: Int) {
	printIndent(pad: pad)
	print("\(name): \(val ?? "<nil>")")
}

private func printCFType(_ ref: CFTypeRef) {
	let typeID = CFGetTypeID(ref)
	if typeID == CFStringGetTypeID() {
		printCFString(ref as! CFString)
	} else if typeID == CFNumberGetTypeID() {
		print(ref as! NSNumber, terminator: "")
	} else {
		print("<Unknown type ID \(typeID)>", terminator: "")
	}
}

/// Converts an `OSType` to a `String` value. May return `nil`.
/// - parameter theType: The `OSType` to convert to a string representation.
/// - returns: A string representation of `theType`, or `nil` if it can't be converted.
private func OSTypeToString(_ theType: OSType) -> String? {
	func OSType2Ptr(type: OSType) -> [UInt8] {
		var ourOSType = [UInt8](repeating: 0, count: 4)
		var intType = type.bigEndian
		memcpy(&ourOSType, &intType, 4)
		
		return ourOSType
	}
	
	let ourOSType = OSType2Ptr(type: theType)
	for char in ourOSType[0..<4] {
		if (UInt8(0)..<0x20).contains(char) {
			return nil
		}
	}
	let ourData = Data(ourOSType)
	return String(data: ourData, encoding: .macOSRoman)
}

private func codecTypeName(_ codecType: CMVideoCodecType) -> String {
	switch(codecType){
		case kCMVideoCodecType_Animation: return "Apple Animation";
		case kCMVideoCodecType_Cinepak: return "Cinepak";
		case kCMVideoCodecType_JPEG: return "JPEG";
		case kCMVideoCodecType_JPEG_OpenDML: return "JPEG with OpenDML extensions";
		case kCMVideoCodecType_SorensonVideo: return "Sorenson Video";
		case kCMVideoCodecType_SorensonVideo3: return "Sorenson 3 Video";
		case kCMVideoCodecType_H263: return "H.263";
		case kCMVideoCodecType_H264: return "AVC/H.264";
		case kCMVideoCodecType_HEVC: return "HEVC/H.265";
		case kCMVideoCodecType_HEVCWithAlpha: return "HEVC/H.265 Alpha"
		case kCMVideoCodecType_DolbyVisionHEVC: return "HEVC/H.265 with Dolby Vision"
		case kCMVideoCodecType_MPEG4Video: return "MPEG4 Video";
		case kCMVideoCodecType_MPEG2Video: return "MPEG2 Video";
		case kCMVideoCodecType_MPEG1Video: return "MPEG Video";
		case kCMVideoCodecType_DVCNTSC: return "DV NTSC";
		case kCMVideoCodecType_DVCPAL: return "DV PAL";
		case kCMVideoCodecType_DVCProPAL: return "DVCPro PAL";
		case kCMVideoCodecType_DVCPro50NTSC: return "DVCPro-50 NTSC";
		case kCMVideoCodecType_DVCPro50PAL: return "DVCPro-50 PAL";
		case kCMVideoCodecType_DVCPROHD720p60: return "DVCPro-HD 720p60";
		case kCMVideoCodecType_DVCPROHD720p50: return "DVCPro-HD 720p50";
		case kCMVideoCodecType_DVCPROHD1080i60: return "DVCPro-HD 1080i60";
		case kCMVideoCodecType_DVCPROHD1080i50: return "DVCPro-HD 1080i50";
		case kCMVideoCodecType_DVCPROHD1080p30: return "DVCPro-HD 1080p30";
		case kCMVideoCodecType_DVCPROHD1080p25: return "DVCPro-HD 1080p25";
		case kCMVideoCodecType_AppleProRes4444XQ: return "ProRes 4444 XQ";
		case kCMVideoCodecType_AppleProRes4444: return "ProRes 4444";
		case kCMVideoCodecType_AppleProRes422HQ: return "ProRes 422 HQ";
		case kCMVideoCodecType_AppleProRes422: return "ProRes 422";
		case kCMVideoCodecType_AppleProRes422LT: return "ProRes 422 LT";
		case kCMVideoCodecType_AppleProRes422Proxy: return "ProRes 422 Proxy";
		case kCMVideoCodecType_AppleProResRAW: return "ProRes RAW";
		case kCMVideoCodecType_AppleProResRAWHQ: return "ProRes RAW HQ";

		case kCMPixelFormat_32ARGB: return "8-bit ARGB";
		case kCMPixelFormat_32BGRA: return "8-bit BGRA";
		case kCMPixelFormat_24RGB: return "8-bit RGB";
		case kCMPixelFormat_16BE555: return "5-bit RGB Big Endian";
		case kCMPixelFormat_16BE565: return "5-6-5 RGB Big Endian";
		case kCMPixelFormat_16LE555: return "5-bit RGB Little Endian";
		case kCMPixelFormat_16LE565: return "5-6-5 RGB Little Endian";
		case kCMPixelFormat_16LE5551: return "5-bit chroma 1-bit alpha RGB Little Endian";
		case kCMPixelFormat_422YpCbCr8: return "8-bit CbY'CrY' 4:2:2";
		case kCMPixelFormat_422YpCbCr8_yuvs: return "8-bit Y'CbY'Cr";
		case kCMPixelFormat_444YpCbCr8: return "8-bit Y'CbCr 4:4:4";
		case kCMPixelFormat_4444YpCbCrA8: return "8-bit Y'CbCrA 4:4:4:4";
		case kCMPixelFormat_422YpCbCr16: return "10 to 16-bit Y'CbCr 4:2:2";
		case kCMPixelFormat_422YpCbCr10: return "10-bit Y'CbCr 4:2:2";
		case kCMPixelFormat_444YpCbCr10: return "10-bit Y'CbCr 4:4:4";
		case kCMPixelFormat_8IndexedGray_WhiteIsZero: return "Indexed Gray-scale";

	case kCMVideoCodecType_VP9:
		return "VP9"
		
		default:
			var errOut = StderrOutputStream()
			print("Unknown code \(codecType)", terminator: "", to: &errOut)
			let hi = { () -> String in
			if let codec = OSTypeToString(codecType) {
				print(": OSType is \(codec)", terminator: "", to: &errOut)
				return "Unknown codec '\(codec)'"
			}
			return "<UNKNOWN>"
			}()
			print(", codecTypeName needs updating!", to: &errOut)
			return hi
	}
}

private func printCodecTypeProperty(name: String, codecType: CMVideoCodecType, pad: Int) {
	printIndent(pad: pad)
	print("\(name): \(codecTypeName(codecType))")
}

private func printSupportedProperty(propInfo: [String: Any], key: String, pad: Int) {
	printIndent(pad: pad)
	print(key)
	
	if let rwStatus = propInfo[kVTPropertyReadWriteStatusKey as String] as? String {
		if rwStatus == (kVTPropertyReadWriteStatus_ReadOnly as String) {
			printIndent(pad: pad + 4)
			print("Value is read-only.")
		} else {
			printIndent(pad: pad + 4)
			print("Value is read-write.")
		}
	}
	
	if let minValue = propInfo[kVTPropertySupportedValueMinimumKey as String] as? NSNumber {
		printIndent(pad: pad + 4)
		print("Minimum value: \(minValue)")
	}
	
	if let maxValue = propInfo[kVTPropertySupportedValueMaximumKey as String] as? NSNumber {
		printIndent(pad: pad + 4)
		print("Maximum value: \(maxValue)")
	}

	if let listOfValues = propInfo[kVTPropertySupportedValueListKey as String] as? [CFTypeRef] {
		for val in listOfValues {
			printIndent(pad: pad + 4)
			printCFType(val)
			print()
		}
	}
}

private func printEncoderSupportedProperties(encoderID: String,
											 codecType: CMVideoCodecType,
											 pad: Int) {
	let encSpec: [String: Any] = [kVTVideoEncoderList_EncoderID as String: encoderID]
	
	var supportedProps: CFDictionary? = nil
	let status = VTCopySupportedPropertyDictionaryForEncoder(width: 1920, height: 1080, codecType: codecType, encoderSpecification: encSpec as NSDictionary, encoderIDOut: nil, supportedPropertiesOut: &supportedProps)
	
	guard status == noErr, let supportedProp = supportedProps as? [String: [String : Any]] else {
		var standardError = StderrOutputStream()
		print("Failed to get supported properties for encoder: \(status)", to: &standardError)
		return
	}
	
	var printedFirstProp = false
	
	for (key, propInfo) in supportedProp {
		
		if !printedFirstProp {
			printIndent(pad: pad)
			print("Supported Properties:")
			printedFirstProp = true;
		}

		printSupportedProperty(propInfo: propInfo, key: key, pad: pad + 4);
	}
}


private func printEncoderProperties(_ encInfo: [String: Any]) {
	let displayName = encInfo[kVTVideoEncoderList_DisplayName as String] as? String
	let codecType: CMVideoCodecType = encInfo[kVTVideoEncoderList_CodecType as String] as? CMVideoCodecType ?? 0xffffffff
	let encoderID = encInfo[kVTVideoEncoderList_EncoderID as String] as? String
	let codecName = encInfo[kVTVideoEncoderList_CodecName as String] as? String
	let encoderName = encInfo[kVTVideoEncoderList_EncoderName as String] as? String

	printStringProperty(name: "Encoder", value: displayName, pad: 0)
	printCodecTypeProperty(name: "Codec Type", codecType: codecType, pad: 4)
	printStringProperty(name: "Encoder ID", value: encoderID, pad: 4)
	printStringProperty(name: "Codec Name", value: codecName, pad: 4)
	printStringProperty(name: "Encoder Name", value: encoderName, pad: 4)

	printEncoderSupportedProperties(encoderID: encoderID!, codecType: codecType, pad: 4);

	print()
}

private func ourRun() {
	var encList: CFArray? = nil
	let status = VTCopyVideoEncoderList(nil, &encList)
	guard status == 0, let encoders = encList as? [[String: Any]] else {
		var standardError = StderrOutputStream()
		
		print("Could not get encoder list: \(status)", to: &standardError)
		exit(-1)
	}
	for encInfo in encoders {
		printEncoderProperties(encInfo)
	}
}

ourRun()
