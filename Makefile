CC = clang
PLATFORM_SDK_PATH=$(shell xcrun --show-sdk-platform-path)
PLATFORM_FRAMEWORKS_PATH=$(PLATFORM_SDK_PATH)/Developer/Library/Frameworks
CFLAGS = -Wall -fobjc-arc -F$(PLATFORM_FRAMEWORKS_PATH)
PROGS = tests


default: $(PROGS)
	DYLD_FRAMEWORK_PATH=$(PLATFORM_FRAMEWORKS_PATH) ./tests 2>&1 | xcpretty -cs

tests: \
	tests.o \
	DecoderTest.o \
	NSDataDecoderTest.o \
	NSData+Base64.o \
	GenericBase64Decoder.o
	$(CC) -o $@ $(CFLAGS) $^ -framework Foundation -framework XCTest

tests.o: \
	tests.m

DecoderTest.o: DecoderTest.m GenericBase64Decoder.h
NSDataDecoderTest.o: NSDataDecoderTest.m NSData+Base64.h
GenericBase64Decoder.o: GenericBase64Decoder.m GenericBase64Decoder.h
NSData+Base64.o: NSData+Base64.m NSData+Base64.h GenericBase64Decoder.h

%.o: %.c
	$(CC) -c $(CFLAGS) $<

%.o: %.m
	$(CC) -c $(CFLAGS) $<

clean:
	rm -f *.o
	rm -f $(PROGS)
