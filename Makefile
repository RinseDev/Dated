THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = Dater
Dater_FILES = Dater.xm
Dater_FRAMEWORKS = UIKit
Dater_PRIVATE_FRAMEWORKS = ChatKit

include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 backboardd"
