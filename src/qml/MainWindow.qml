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
    menuBar: MenuBar {
        MenuItem {
            text: qsTr("Refresh")
            onTriggered: feed.refresh()
        }
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
                source: icon ? icon : "image://icon/hildonevents"
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
                    wrapMode: Text.Wrap
                    font.pointSize: platformStyle.fontSizeSmall
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
                                    source: video ? "/etc/hildon/theme/mediaplayer/Play.png" : ""
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
    
    Component.onCompleted: eventModel.reload()
}
