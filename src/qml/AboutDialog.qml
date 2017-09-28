/*
 * Copyright (C) 2017 Stuart Howarth <showarth@marxoft.co.uk>
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

Dialog {
    id: root

    title: qsTr("About")
    height: Math.min(360, flow.height + platformStyle.paddingMedium)

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: flow.height
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

        Flow {
            id: flow

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            spacing: platformStyle.paddingMedium

            Image {
                id: icon

                width: 64
                height: 64
                source: "image://icon/hildonevents"
            }

            Label {
                width: flow.width - icon.width - flow.spacing
                height: icon.height
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pointSize: platformStyle.fontSizeLarge
                text: "Hildon Event Feed 0.6.0"
            }

            Label {
                width: flow.width
                wrapMode: Text.WordWrap
                text: qsTr("Hildon Event Feed provides an event feed for Maemo5, similar to that in Meego-Harmattan.")
                + "<br><br>"
                + qsTr("Keyboard shortcuts:")
                + "<br><br>"
                + qsTr("D: Remove current item from the event feed.")
                + "<br>"
                + qsTr("Shift+D: Remove all items from the current source from the event feed.")
                + "<br>"
                + qsTr("Ctrl+R: Refresh the event feed.")
                + "<br>"
                + qsTr("Ctrl+P: Show the settings window.")
                + "<br>"
                + qsTr("Ctrl+Q: Quit the application.")
                + "<br><br>&copy; Stuart Howarth 2017"
            }
        }
    }

    contentItem.states: State {
        name: "Portrait"
        when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation

        PropertyChanges {
            target: root
            height: Math.min(680, flow.height + platformStyle.paddingMedium)
        }
    }
}
