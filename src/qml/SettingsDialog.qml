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
import org.hildon.eventfeed 1.0

Dialog {
    id: root
    
    height: grid.height + platformStyle.paddingMedium
    title: qsTr("Application")
    
    Grid {
        id: grid
        
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: platformStyle.paddingMedium
        columns: 2
        
        ListSelectorButton {
            id: orientationButton
            
            width: grid.width - acceptButton.width - grid.spacing
            text: qsTr("Screen orientation")
            model: ScreenOrientationModel {}
            value: settings.screenOrientation
            onSelected: settings.screenOrientation = value
        }
        
        Button {
            id: acceptButton
            
            style: DialogButtonStyle {}
            text: qsTr("Done")
            onClicked: root.accept()
        }
    }

    contentItem.states: State {
        name: "Portrait"
        when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation

        PropertyChanges {
            target: grid
            columns: 1
        }

        PropertyChanges {
            target: orientationButton
            width: grid.width
        }

        PropertyChanges {
            target: acceptButton
            width: grid.width
        }
    }
}
