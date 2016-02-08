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

#include "database.h"
#include "eventfeed.h"
#include "eventfeedui.h"
#include "settings.h"
#include <QApplication>
#include <QStringList>

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    app.setOrganizationName("HildonEvents");
    app.setApplicationName("Event Feed");
    app.setApplicationVersion("0.5.0");
    app.setQuitOnLastWindowClosed(false);
    
    initDatabase();
    
    QScopedPointer<EventFeed> feed(EventFeed::instance());
    QScopedPointer<EventFeedUi> ui(EventFeedUi::instance());
    QScopedPointer<Settings> settings(Settings::instance());
    
    const QStringList args = app.arguments();
    
    if (args.contains("--window")) {
        ui.data()->showWindow();
    }
    
    if (args.contains("--widget")) {
        ui.data()->showWidget();
    }
        
    return app.exec();
}
