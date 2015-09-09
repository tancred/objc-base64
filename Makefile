CC = clang
PLATFORM_SDK_PATH=$(shell xcrun --show-sdk-platform-path)
PLATFORM_FRAMEWORKS_PATH=$(PLATFORM_SDK_PATH)/Developer/Library/Frameworks
CFLAGS = -Wall -fobjc-arc -F$(PLATFORM_FRAMEWORKS_PATH)
PROGS = tests


default: $(PROGS)
	DYLD_FRAMEWORK_PATH=$(PLATFORM_FRAMEWORKS_PATH) ./tests 2>&1 | xcpretty -cs

tests: \
	tests.o \
	DecoderTest.o
	$(CC) -o $@ $(CFLAGS) $^ -framework Foundation -framework XCTest

tests.o: \
	tests.m

DecoderTest.o: DecoderTest.m

%.o: %.c
	$(CC) -c $(CFLAGS) $<

%.o: %.m
	$(CC) -c $(CFLAGS) $<

clean:
	rm -f *.o
	rm -f $(PROGS)
