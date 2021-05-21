//
//  StderrOutputStream.swift
//  VTEncoderInfoSwift
//
//  Created by C.W. Betts on 5/11/21.
//

import Swift
import func Darwin.fputs
import var Darwin.stderr

struct StderrOutputStream: TextOutputStream {
	mutating func write(_ string: String) {
		fputs(string, stderr)
	}
}
