/*
 * Copyright (C) 2016 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.0
import org.hildon.components 1.0
import org.hildon.utils 1.0
import org.hildon.eventfeed 1.0

Window {
    id: root
    
    title: qsTr("Settings")
    
    Flickable {
        id: flickable
        
        anchors.fill: parent
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        contentHeight: flow.height + platformStyle.paddingLarge
        
        Flow {
            id: flow
            
            property int buttonWidth: Math.floor((width - spacing) / 2)
                        
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: platformStyle.paddingLarge
            }
            spacing: platformStyle.paddingLarge
            
            SeparatorLabel {
                width: flow.width
                text: qsTr("Event Feed")
            }
            
            SettingsButton {
                width: flow.buttonWidth
                text: qsTr("Homescreen widget")
                iconName: "hildonevents"
                onClicked: internal.settings = widgetDialog.createObject(root)
            }
            
            SeparatorLabel {
                width: flow.width
                text: qsTr("Feeds")
            }
            
            Repeater {
                id: repeater

                model: SettingsModel {
                    id: settingsModel
                }
                
                SettingsButton {
                    width: flow.buttonWidth
                    text: name
                    iconSource: icon ? (icon.indexOf("/") == -1 ? "image://icon/" : "") + icon
                                     : "image://icon/general_settings"
                    onClicked: {
                        if (type == "qml") {
                            if (internal.settings) {
                                internal.settings.destroy();
                            }
                            
                            var component = Qt.createComponent(Qt.resolvedUrl(exec));
                            internal.settings = component.createObject(root);
                            internal.settings.visible = true;
                        }
                        else if (type == "application") {
                            process.command = exec;
                            process.start();
                        }
                    }
                }
            }
        }
    }
    
    Label {
        anchors.centerIn: parent
        font.pointSize: platformStyle.fontSizeXLarge
        color: platformStyle.disabledTextColor
        text: qsTr("No settings")
        visible: settingsModel.count == 0
    }
    
    Process {
        id: process
    }
    
    QtObject {
        id: internal
        
        property QtObject settings: null
    }
    
    Component {
        id: widgetDialog
        
        WidgetSettingsDialog {
            Component.onCompleted: open()
        }
    }
    
    Component.onCompleted: settingsModel.reload()
}
