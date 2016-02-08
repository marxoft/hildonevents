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

AbstractButton {
    id: root
    
    width: 150
    height: 70
    
    BorderImage {
        id: background
        
        anchors.fill: parent
        border {
            left: 2
            right: 2
            top: 2
            bottom: 2
        }
        smooth: true
        source: root.pressed ? "image://theme/qgn_plat_focus_selection" : ""
    }
    
    Image {
        id: icon
        
        anchors {
            left: parent.left
            leftMargin: platformStyle.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        width: 48
        height: 48
        smooth: true
        source: root.iconSource ? root.iconSource : iconName ? "image://icon/" + root.iconName : ""
    }
    
    Text {
        id: label
        
        anchors {
            left: icon.right
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: platformStyle.paddingMedium
        }
        elide: Text.ElideRight
        style: Text.Raised
        color: platformStyle.defaultTextColor
        text: root.text
    }
}
