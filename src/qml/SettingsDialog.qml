/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
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

Dialog {
    id: root
    
    height: 350
    title: qsTr("Settings")
    
    ListView {
        id: view
        
        anchors.fill: parent
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: SettingsModel {
            id: settingsModel
        }
        delegate: ListItem {
            Row {
                anchors.centerIn: parent
                height: 48
                spacing: platformStyle.paddingMedium
                
                Image {                
                    width: 48
                    height: 48
                    source: icon ? (icon.indexOf("/") == -1 ? "image://icon/" : "") + icon : ""
                    smooth: true
                    visible: source != ""
                }
            
                Label {
                    height: 48
                    verticalAlignment: Text.AlignVCenter
                    text: name
                }
            }
            
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
        section.property: "category"
        section.delegate: Label {
            width: view.width
            height: 48
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: platformStyle.secondaryTextColor
            text: section
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
    
    Component.onCompleted: settingsModel.reload()
}
