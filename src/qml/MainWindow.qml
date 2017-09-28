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
import org.hildon.eventfeed 1.0

ApplicationWindow {
    id: window
    
    visible: true
    title: qsTr("Event Feed")
    showProgressIndicator: feed.refreshing
    menuBar: MenuBar {
        MenuItem {
            action: refreshAction
        }
        
        MenuItem {
            action: settingsAction
        }

        MenuItem {
            action: quitAction
        }
    }

    Action {
        id: refreshAction

        text: feed.refreshing ? qsTr("Cancel refresh") : qsTr("Refresh")
        shortcut: qsTr("Ctrl+R")
        autoRepeat: false
        onTriggered: feed.refreshing ? feed.cancelRefresh() : feed.refresh()
    }

    Action {
        id: settingsAction

        text: qsTr("Settings")
        shortcut: qsTr("Ctrl+P")
        autoRepeat: false
        onTriggered: windowStack.push(Qt.resolvedUrl("SettingsWindow.qml"))
    }

    Action {
        id: quitAction

        text: qsTr("Quit")
        shortcut: qsTr("Ctrl+Q")
        autoRepeat: false
        onTriggered: feed.refreshing ? popupManager.open(quitDialog, window) : Qt.quit()
    }

    Action {
        id: removeAction

        shortcut: qsTr("D")
        autoRepeat: false
        enabled: view.currentIndex != -1
        onTriggered: feed.removeItem(eventModel.data(view.currentIndex, "id"))
    }

    Action {
        id: removeSourceAction

        shortcut: qsTr("Shift+D")
        autoRepeat: false
        enabled: view.currentIndex != -1
        onTriggered: feed.removeItemsBySourceName(eventModel.data(view.currentIndex, "sourceName"))
    }
    
    FontMetrics {
        id: bodyFontMetrics
        
        font.pointSize: platformStyle.fontSizeSmall
    }
    
    ListView {
        id: view
        
        anchors.fill: parent
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        cacheBuffer: 800
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
            onPressAndHold: popupManager.open(contextMenu, window)
        }
    }
    
    Label {
        anchors.centerIn: parent
        font.pointSize: platformStyle.fontSizeXLarge
        color: platformStyle.disabledTextColor
        text: qsTr("No events")
        visible: eventModel.count == 0
    }

    Component {
        id: contextMenu

        Menu {
            MenuItem {
                text: qsTr("Remove")
                onTriggered: feed.removeItem(eventModel.data(view.currentIndex, "id"))
            }
            
            MenuItem {
                text: qsTr("Remove") + " " + eventModel.data(view.currentIndex, "sourceDisplayName")
                onTriggered: feed.removeItemsBySourceName(eventModel.data(view.currentIndex, "sourceName"))
            }
        }
    }

    Component {
        id: quitDialog

        MessageBox {
            text: qsTr("The event feed is currently being refreshed. Quit anyway?")
            onAccepted: Qt.quit()
        }
    }

    Binding {
        target: screen
        property: "orientationLock"
        value: settings.screenOrientation
    }
    
    Component.onCompleted: eventModel.reload()
}
