TARGET = hildonevents
QT += dbus declarative sql

#DEFINES += DEBUG

HEADERS = \
    src/database.h \
    src/eventfeed.h \
    src/eventfeedui.h \
    src/eventmodel.h \
    src/json.h \
    src/settingsmodel.h

SOURCES = \
    src/eventfeed.cpp \
    src/eventfeedui.cpp \
    src/eventmodel.cpp \
    src/json.cpp \
    src/main.cpp \
    src/settingsmodel.cpp

qml.files = \
    src/qml/MainWindow.qml \
    src/qml/SettingsDialog.qml \
    src/qml/Widget.qml

qml.path = /opt/hildonevents/qml

dbus_service.files = \
    dbus/org.hildon.eventfeed.service \
    dbus/org.hildon.eventfeed.ui.service

dbus_service.path = /usr/share/dbus-1/services

dbus_interface.files = \
    dbus/org.hildon.eventfeed.xml \
    dbus/org.hildon.eventfeed.ui.xml

dbus_interface.path = /usr/share/dbus-1/interfaces

desktop.files = desktop/hildonevents.desktop
desktop.path = /usr/share/applications/hildon

widget.files = desktop/widget/hildonevents.desktop
widget.path = /usr/share/applications/hildon-home

icon.files = desktop/64/hildonevents.png
icon.path = /usr/share/icons/hicolor/64x64/apps

scripts.files = \
    src/scripts/showwidget \
    src/scripts/showwindow

scripts.path = /opt/hildonevents/bin

target.path = /opt/hildonevents/bin

INSTALLS += \
    target \
    qml \
    dbus_service \
    dbus_interface \
    desktop \
    widget \
    icon \
    scripts
