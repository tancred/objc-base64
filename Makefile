default:
	xcodebuild -scheme ObjcBase64 test 2>&1 | xcpretty -cs

clean:
	xcodebuild -scheme ObjcBase64 clean 2>&1 | xcpretty -cs
