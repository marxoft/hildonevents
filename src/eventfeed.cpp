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

#include "eventfeed.h"
#include "database.h"
#include "json.h"
#include <QDateTime>
#include <QDBusConnection>
#include <QDesktopServices>
#include <QProcess>
#include <QUrl>
#ifdef DEBUG
#include <QDebug>
#endif

EventFeed* EventFeed::self = 0;

EventFeed::EventFeed() :
    QObject(),
    m_refreshProcess(0)
{
    self = this;
    
    QDBusConnection connection = QDBusConnection::sessionBus();
    connection.registerService("org.hildon.eventfeed");
    connection.registerObject("/org/hildon/eventfeed", this, QDBusConnection::ExportScriptableContents);
}

EventFeed::~EventFeed() {
    self = 0;
}

EventFeed* EventFeed::instance() {
    return self ? self : self = new EventFeed;
}

bool EventFeed::isRefreshing() const {
    return !m_refreshActions.isEmpty();
}

qlonglong EventFeed::addItem(const QVariantMap &parameters) {
#ifdef DEBUG
    qDebug() << "EventFeed::addItem" << parameters;
#endif
    if ((!parameters.contains("title")) || (!parameters.contains("url")) || (!parameters.contains("sourceName"))
        || (!parameters.contains("sourceDisplayName"))) {
        return -1;
    }
        
    QSqlQuery query(getDatabase());
    query.prepare("INSERT INTO events VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    query.addBindValue(QVariant::Int);
    query.addBindValue(parameters.value("icon"));
    query.addBindValue(parameters.value("title"));
    query.addBindValue(parameters.value("body"));
    query.addBindValue(QtJson::Json::serialize(parameters.value("imageList").toList()));
    query.addBindValue(parameters.contains("timestamp") ? parameters.value("timestamp") : QDateTime::currentDateTime());
    query.addBindValue(parameters.value("footer"));
    query.addBindValue(parameters.value("video"));
    query.addBindValue(parameters.value("url"));
    query.addBindValue(parameters.value("action"));
    query.addBindValue(parameters.value("sourceName"));
    query.addBindValue(parameters.value("sourceDisplayName"));
    
    if ((query.exec()) && (query.exec("SELECT last_insert_rowid()")) && (query.next())) {
        const qlonglong id = query.value(0).toLongLong();
        emit itemAdded(id);
        return id;
    }
    
    return -1;
}

void EventFeed::addRefreshAction(const QString &action) {
#ifdef DEBUG
    qDebug() << "EventFeed::addRefreshAction" << action;
#endif
    if (action.isEmpty()) {
        return;
    }
    
    QSqlQuery query(getDatabase());
    query.prepare("INSERT OR IGNORE INTO refreshActions VALUES (?)");
    query.addBindValue(action);
    query.exec();
}

void EventFeed::removeItem(qlonglong id) {
#ifdef DEBUG
    qDebug() << "EventFeed::removeItem" << id;
#endif
    QSqlQuery query(getDatabase());
    query.prepare("DELETE FROM events WHERE id = ?");
    query.addBindValue(id);
    
    if (query.exec()) {
        emit itemRemoved(id);
    }
}

void EventFeed::removeItemsBySourceName(const QString &sourceName) {
#ifdef DEBUG
    qDebug() << "EventFeed::removeItemsBySourceName" << sourceName;
#endif
    QSqlQuery query(getDatabase());
    query.prepare("DELETE FROM events WHERE sourceName = ?");
    query.addBindValue(sourceName);
    
    if (query.exec()) {
        emit itemsRemoved(sourceName);
    }
}

void EventFeed::removeRefreshAction(const QString &action) {
#ifdef DEBUG
    qDebug() << "EventFeed::removeRefreshAction" << action;
#endif
    QSqlQuery query(getDatabase());
    query.prepare("DELETE FROM refreshActions WHERE action = ?");
    query.addBindValue(action);
    query.exec();
}

void EventFeed::updateItem(qlonglong id, const QVariantMap &parameters) {
#ifdef DEBUG
    qDebug() << "EventFeed::updateItem" << id << parameters;
#endif
    if (parameters.contains("id")) {
        return;
    }
    
    QSqlQuery query(getDatabase());
    QString statement = QString("UPDATE events SET %1 = ? WHERE id = %2")
                               .arg(QStringList(parameters.keys()).join(" = ?, "))
                               .arg(id);
    query.prepare(statement);
    
    foreach (QVariant value, parameters.values()) {
        switch (value.type()) {
        case QVariant::List:
        case QVariant::StringList:
            query.addBindValue(QtJson::Json::serialize(value));
            break;
        default:
            query.addBindValue(value);
            break;
        }
    }
    
    if (query.exec()) {
        emit itemUpdated(id);
    }
}

void EventFeed::openItem(qlonglong id) {
    QSqlQuery query(getDatabase());
    query.prepare("SELECT url, action FROM events WHERE id = ?");
    query.addBindValue(id);
    
    if ((query.exec()) && (query.next())) {
        const QString action = query.value(1).toString();
        
        if (!action.isEmpty()) {
            QProcess::startDetached(action);
        }
        else {
            QDesktopServices::openUrl(query.value(0).toUrl());
        }
    }
}

void EventFeed::refresh() {
    if (isRefreshing()) {
        return;
    }
    
    QSqlQuery query(getDatabase());
    
    if (query.exec("SELECT action FROM refreshActions")) {
        while (query.next()) {
            m_refreshActions << query.value(0).toString();
        }
    }
    
    if (!m_refreshActions.isEmpty()) {
        nextRefreshAction();
        emit refreshingChanged();
    }
    
    emit refreshRequested();
}

void EventFeed::cancelRefresh() {
    if (!isRefreshing()) {
        return;
    }
    
    m_refreshActions.clear();
    
    if ((!m_refreshProcess) || (m_refreshProcess->state() == QProcess::NotRunning)) {
        emit refreshingChanged();
    }
    else {
        m_refreshProcess->kill();
    }
}

void EventFeed::nextRefreshAction() {
    if (m_refreshActions.isEmpty()) {
        return;
    }
    
    if (!m_refreshProcess) {
        m_refreshProcess = new QProcess(this);
        connect(m_refreshProcess, SIGNAL(error(QProcess::ProcessError)), this, SLOT(onRefreshFinished()));
        connect(m_refreshProcess, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(onRefreshFinished()));
    }
    
    if (m_refreshProcess->state() == QProcess::NotRunning) {
        m_refreshProcess->start(m_refreshActions.first());
    }
}

void EventFeed::onRefreshFinished() {
    if (!m_refreshActions.isEmpty()) {
        m_refreshActions.removeFirst();
    }
    
    if (!m_refreshActions.isEmpty()) {
        nextRefreshAction();
    }
    else {
        emit refreshingChanged();
    }
}
