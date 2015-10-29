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
        <td>The path to the item's icon.</td>
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

###updateItem

Signature: ia{s,v}

Updates the item with the specified unique identifer using the supplied parameters. See the **addItem** method for the 
list of acceptable parameters.

##D-Bus signals

###refreshRequested

Emitted when the 'refresh' button is pressed in the user interface.
