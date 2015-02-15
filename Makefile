THEOS_PACKAGE_DIR_NAME = debs
TARGET = iphone:clang:latest:6.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Dated
Dated_FILES = Dated.xm
Dated_FRAMEWORKS = UIKit CoreGraphics
Dated_PRIVATE_FRAMEWORKS = ChatKit IMCore
Dated_LIBRARIES = cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += DatedPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 MobileSMS; killall -9 Preferences"
