TARGET =: clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = DatedPrefs
DatedPrefs_FILES = DatedPrefs.xm
DatedPrefs_INSTALL_PATH = /Library/PreferenceBundles
DatedPrefs_FRAMEWORKS = UIKit Twitter CoreFoundation
DatedPrefs_PRIVATE_FRAMEWORKS = Preferences ChatKit

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DatedPrefs.plist$(ECHO_END)
