#Hildon Event Feed

Hildon Event Feed provides an event feed for Maemo5, similar to that in Meego-Harmattan. Applications 
can interact with the event feed using D-Bus.

##D-Bus interface

Service name: org.hildon.eventfeed

Path: /org/hildon/eventfeed

Interface name: org.hildon.eventfeed

##D-Bus methods

###addItem

Signature: a{s,v}

Returns: i

Adds an item to the event feed using the supplied parameters, and returns a unique identifer for the item, or -1 if 
there is an error.

The following parameters can be supplied:

<table>
    <tr>
        <th>Name</th>
        <th>Type</th>
        <th>Mandatory</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>icon</td>
        <td>string</td>
        <td>No</td>
        <td>The absolute path or name of the item's icon.</td>
    </tr>
    <tr>
        <td>title</td>
        <td>string</td>
        <td>Yes</td>
        <td>The item title.</td>
    </tr>
    <tr>
        <td>body</td>
        <td>string</td>
        <td>No</td>
        <td>The item description.</td>
    </tr>
    <tr>
        <td>imageList</td>
        <td>array(string)</td>
        <td>No</td>
        <td>A list of paths to the item's images.</td>
    </tr>
    <tr>
        <td>timestamp</td>
        <td>datetime</td>
        <td>No</td>
        <td>The timestamp for the item in ISO 8601 format (YYYY-MM-DDTHH:mm:ss).</td>
    </tr>
    <tr>
        <td>footer</td>
        <td>string</td>
        <td>No</td>
        <td>The item's footer.</td>
    </tr>
    <tr>
        <td>video</td>
        <td>boolean</td>
        <td>No</td>
        <td>Whether the item represents a video.</td>
    </tr>
    <tr>
        <td>url</td>
        <td>string</td>
        <td>Yes</td>
        <td>The item's url.</td>
    </tr>
    <tr>
        <td>action</td>
        <td>string</td>
        <td>No</td>
        <td>The custom command to be executed when the item is activated.</td>
    </tr>
    <tr>
        <td>sourceName</td>
        <td>string</td>
        <td>Yes</td>
        <td>A unique identifier for item's source, such as the application name.</td>
    </tr>
    <tr>
        <td>sourceDisplayName</td>
        <td>string</td>
        <td>No</td>
        <td>The display name of the item's source.</td>
    </tr>
</table>

###addRefreshAction

Signature: s

Adds an action to the event feed that consists of a command that is to be executed when 
the 'refresh' button is pressed in the user interface, enabling the user to retrieve further events from the source.

###removeItem

Signature: i

Removes the item with the specified unique identifier.

###removeItemsBySourceName

Signature: s

Removes all items with the specified source name.

###removeRefreshAction

Signature: s

Removes the specified refresh action.

###updateItem

Signature: ia{s,v}

Updates the item with the specified unique identifer using the supplied parameters. See the **addItem** method for the 
list of acceptable parameters.

##D-Bus signals

###refreshRequested

Emitted when the 'refresh' button is pressed in the user interface.

##Settings API

Hildon Event Feed can display settings for individual feeds via the settings API. To provide settings for a feed, place 
a *.desktop file in **/opt/hildonevents/settings/**. The *.desktop should provide the following values:

<table>
    <tr>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>Name</td>
        <td>The feed's display name.</td>
    </tr>
    <tr>
        <td>Icon</td>
        <td>The absolute path or name of the feed's icon.</td>
    </tr>
    <tr>
        <td>Type</td>
        <td>The settings type. Can be 'QML' or 'Application'.</td>
    </tr>
    <tr>
        <td>Exec</td>
        <td>The path to the QML file or executable.</td>
    </tr>
</table>

###Example

An example settings desktop file for 'My Feed':

    [Desktop Entry]
    Name=My Feed
    Icon=myfeed
    Type=QML
    Exec=/opt/myfeed/qml/SettingsDialog.qml

An example settings dialog for 'My Feed':

    import QtQuick 1.0
    import org.hildon.components 1.0
    import org.hildon.settings 1.0
    
    Dialog {
        id: dialog
        
        title: "My Feed Settings"
        height: column.height + platformStyle.paddingMedium
        
        GConfItem {
            id: gconf
            
            key: "/apps/myfeed/feed_url"
        }
        
        Column {
            id: column
            
            anchors {
                left: parent.left
                right: button.left
                rightMargin: platformStyle.paddingMedium
                bottom: parent.bottom
            }
            spacing: platformStyle.paddingMedium
            
            Label {
                width: parent.width
                text: "Feed URL"
            }
            
            TextField {
                id: textField
                
                width: parent.width
                text: gconf.value
            }
        }
        
        Button {
            id: button
            
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            style: DialogButtonStyle {}
            text: "Done"
            enabled: textField.text != ""
            onClicked: dialog.accept()
        }
        
        onAccepted: gconf.value = textField.text
    }
