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
import org.hildon.desktop 1.0
import org.hildon.eventfeed 1.0

HomescreenWidget {
    id: widget
    
    width: 300
    height: 332
    pluginId: "hildonevents.desktop-0"
    settingsAvailable: true
    
    Rectangle {
        id: background
        
        anchors {
            fill: parent
            rightMargin: 1
            bottomMargin: 1
        }
        color: platformStyle.defaultBackgroundColor
        opacity: 0.8
        border {
            width: 1
            color: platformStyle.selectionColor
        }
    }
    
    ListView {
        id: view
        
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: buttonRow.top
            margins: 2
        }
        clip: true
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: EventModel {
            id: eventModel
        }
        delegate: ListItem {
            style: OssoListItemStyle {
                background: ""
                itemHeight: 70
            }
            
            Image {
                id: iconImage
                
                anchors {
                    left: parent.left
                    leftMargin: platformStyle.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                width: 28
                height: 28
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: icon ? (icon.indexOf("/") == -1 ? "image://icon/" : "") + icon : "image://icon/hildonevents"
            }
            
            Label {
                id: titleLabel
                
                anchors {
                    left: iconImage.right
                    right: parent.right
                    top: parent.top
                    margins: platformStyle.paddingMedium
                }
                elide: Text.ElideRight
                font.pointSize: platformStyle.fontSizeSmall
                text: title
            }
            
            Label {
                id: footerLabel
                
                anchors {
                    left: iconImage.right
                    right: parent.right
                    bottom: parent.bottom
                    margins: platformStyle.paddingMedium
                }
                elide: Text.ElideRight
                color: platformStyle.secondaryTextColor
                font.pointSize: platformStyle.fontSizeSmall
                text: (footer ? footer + " | " : "")  + timestampString
            }
            
            onClicked: feed.openItem(id)
        }
        
        Label {
            anchors.centerIn: parent
            text: qsTr("No events")
            visible: eventModel.count == 0
        }
    }
    
    ToolButtonStyle {
        id: buttonStyle
        
        background: ""
        backgroundDisabled: ""
        backgroundMarginLeft: 10
        backgroundMarginRight: 10
        backgroundMarginTop: 10
        backgroundMarginBottom: 10
    }
    
    Row {
        id: buttonRow
        
        property int buttonWidth: Math.floor(width / 3)
        
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 2
        }
        
        ToolButton {
            id: upButton
            
            width: buttonRow.buttonWidth
            height: 48
            style: buttonStyle
            iconName: "rss_reader_move_up"
            onClicked: view.currentIndex = Math.max(0, view.currentIndex - 4)            
        }
        
        ToolButton {
            id: reloadButton
            
            width: buttonRow.buttonWidth
            height: 48
            style: buttonStyle
            iconName: "general_refresh"
            onClicked: feed.refresh()
        }
        
        ToolButton {
            id: downButton
            
            width: buttonRow.buttonWidth
            height: 48
            style: buttonStyle
            iconName: "rss_reader_move_down"
            onClicked: view.currentIndex = Math.min(view.count - 1, view.currentIndex + 4)            
        }
    }
    
    Component {
        id: settingsDialog
        
        SettingsDialog {
            onStatusChanged: if (status == DialogStatus.Closed) destroy();
        }
    }
    
    onSettingsRequested: settingsDialog.createObject(widget)
    
    Component.onCompleted: eventModel.reload()
}
