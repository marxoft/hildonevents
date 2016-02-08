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

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QDir>

static const QString DATABASE_PATH("/home/user/.local/share/data/hildonevents/");
static const QString DATABASE_NAME("eventfeed.db");

inline static QSqlDatabase getDatabase() {
    QSqlDatabase db = QSqlDatabase::database();

    if (!db.isOpen()) {
        db.open();
    }
    
    return db;
}

inline static void initDatabase() {
    QDir().mkpath(DATABASE_PATH);
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(DATABASE_PATH + DATABASE_NAME);
    
    if (!db.isOpen()) {
        db.open();
    }
    
    db.exec("CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY NOT NULL, icon TEXT, title TEXT, body TEXT, \
    imageList TEXT, timestamp TEXT, footer TEXT, video INTEGER, url TEXT, action TEXT, sourceName TEXT, \
    sourceDisplayName TEXT)");
    
    db.exec("CREATE TABLE IF NOT EXISTS refreshActions (action TEXT UNIQUE)");
}
