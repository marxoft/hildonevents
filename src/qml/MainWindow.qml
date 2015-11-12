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
import org.hildon.eventfeed 1.0

Window {
    id: window
    
    visible: true
    title: qsTr("Event Feed")
    showProgressIndicator: feed.refreshing
    menuBar: MenuBar {
        MenuItem {
            text: feed.refreshing ? qsTr("Cancel refresh") : qsTr("Refresh")
            onTriggered: feed.refreshing ? feed.cancelRefresh() : feed.refresh()
        }
        
        MenuItem {
            text: qsTr("Settings")
            onTriggered: settingsDialog.createObject(window)
        }
    }
    
    FontMetrics {
        id: bodyFontMetrics
        
        font.pointSize: platformStyle.fontSizeSmall
    }
    
    ListView {
        id: view
        
        anchors.fill: parent
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: EventModel {
            id: eventModel
        }
        delegate: ListItem {
            height: Math.max(iconImage.height, column.height) + platformStyle.paddingMedium * 2
            
            Image {
                id: iconImage

                anchors {
                    left: parent.left
                    top: parent.top
                    margins: platformStyle.paddingMedium
                }
                width: 64
                height: 64
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: icon ? (icon.indexOf("/") == -1 ? "image://icon/" : "") + icon : "image://icon/hildonevents"
            }
            
            Column {
                id: column
                
                anchors {
                    left: iconImage.right
                    right: parent.right
                    top: parent.top
                    margins: platformStyle.paddingMedium
                }
                spacing: platformStyle.paddingMedium
            
                Label {
                    id: titleLabel
                
                    width: parent.width
                    height: iconImage.height
                    elide: Text.ElideRight
                    text: title
                }
            
                Label {
                    id: bodyLabel
                    
                    width: parent.width
                    height: Math.min(paintedHeight, bodyFontMetrics.height * 4)
                    clip: true
                    wrapMode: Text.Wrap
                    font.pointSize: platformStyle.fontSizeSmall
                    textFormat: Text.PlainText
                    text: body
                }
                
                Loader {
                    id: imageListLoader
                    
                    width: parent.width
                    height: item ? 96 : 0
                    sourceComponent: imageList.length > 0 ? imageListComponent : undefined
                }
            
                Label {
                    id: footerLabel
                
                    width: parent.width
                    elide: Text.ElideRight
                    color: platformStyle.secondaryTextColor
                    font.pointSize: platformStyle.fontSizeSmall
                    text: (footer ? footer + " | " : "")  + timestampString
                }
                
                Component {
                    id: imageListComponent
                    
                    Row {
                        spacing: platformStyle.paddingMedium
                        
                        Repeater {
                            model: Math.min(imageList.length, 2)
                            
                            Image {
                                width: Math.min(sourceSize.width, 96)
                                height: Math.min(sourceSize.height, 96)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                source: imageList[index]
                                
                                Image {
                                    anchors.centerIn: parent
                                    width: 48
                                    height: 48
                                    smooth: true
                                    source: (video) && (parent.status == Image.Ready)
                                            ? "/etc/hildon/theme/mediaplayer/Play.png" : ""
                                }
                            }
                        }
                    }
                }
            }
            
            onClicked: feed.openItem(id)
            onPressAndHold: contextMenu.popup()
        }
    }
    
    Label {
        anchors.centerIn: parent
        font.pointSize: platformStyle.fontSizeXLarge
        color: platformStyle.disabledTextColor
        text: qsTr("No events")
        visible: eventModel.count == 0
    }
    
    Menu {
        id: contextMenu
        
        MenuItem {
            text: qsTr("Remove")
            onTriggered: feed.removeItem(eventModel.data(view.currentIndex, "id"))
        }
        
        MenuItem {
            text: qsTr("Remove") + " " + eventModel.data(view.currentIndex, "sourceDisplayName")
            onTriggered: feed.removeItemsBySourceName(eventModel.data(view.currentIndex, "sourceName"))
        }
    }
    
    Component {
        id: settingsDialog
        
        SettingsDialog {
            onStatusChanged: if (status == DialogStatus.Closed) destroy();
            
            Component.onCompleted: open()
        }
    }
    
    Component.onCompleted: eventModel.reload()
}
