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

#include "eventmodel.h"
#include "eventfeed.h"
#include "database.h"
#include "json.h"
#include <QDateTime>

static void setItemDataFromQuery(QStandardItem *item, const QSqlQuery &query) {
    item->setData(query.value(0), EventModel::IdRole);
    item->setData(query.value(1), EventModel::IconRole);
    item->setData(query.value(2), EventModel::TitleRole);
    item->setData(query.value(3), EventModel::BodyRole);
    item->setData(QtJson::Json::parse(query.value(4).toString()), EventModel::ImageListRole);
    item->setData(query.value(5), EventModel::TimestampRole);
    item->setData(query.value(5).toDateTime().toString("dd/MM/yyyy HH:mm"), EventModel::TimestampStringRole);
    item->setData(query.value(6), EventModel::FooterRole);
    item->setData(query.value(7), EventModel::VideoRole);
    item->setData(query.value(8), EventModel::UrlRole);
    item->setData(query.value(9), EventModel::ActionRole);
    item->setData(query.value(10), EventModel::SourceNameRole);
    item->setData(query.value(11), EventModel::SourceDisplayNameRole);
}

EventModel::EventModel(QObject *parent) :
    QStandardItemModel(parent)
{    
    m_roles[IdRole] = "id";
    m_roles[IconRole] = "icon";
    m_roles[TitleRole] = "title";
    m_roles[BodyRole] = "body";
    m_roles[ImageListRole] = "imageList";
    m_roles[TimestampRole] = "timestamp";
    m_roles[TimestampStringRole] = "timestampString";
    m_roles[FooterRole] = "footer";
    m_roles[VideoRole] = "video";
    m_roles[UrlRole] = "url";
    m_roles[ActionRole] = "action";
    m_roles[SourceNameRole] = "sourceName";
    m_roles[SourceDisplayNameRole] = "sourceDisplayName";
#if QT_VERSION < 0x050000
    setRoleNames(m_roles);
#endif
    setSortRole(TimestampRole);
    
    connect(this, SIGNAL(rowsInserted(QModelIndex, int, int)), this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex, int, int)), this, SIGNAL(countChanged()));
    connect(EventFeed::instance(), SIGNAL(itemAdded(qlonglong)), this, SLOT(onItemAdded(qlonglong)));
    connect(EventFeed::instance(), SIGNAL(itemRemoved(qlonglong)), this, SLOT(onItemRemoved(qlonglong)));
    connect(EventFeed::instance(), SIGNAL(itemsRemoved(QString)), this, SLOT(onItemsRemoved(QString)));
    connect(EventFeed::instance(), SIGNAL(itemUpdated(qlonglong)), this, SLOT(onItemUpdated(qlonglong)));
}

#if QT_VERSION >= 0x050000
QHash<int, QByteArray> EventModel::roleNames() const {
    return m_roles;
}
#endif

QVariant EventModel::data(int row, const QByteArray &roleName) const {
    return QStandardItemModel::data(index(row, 0, QModelIndex()), m_roles.key(roleName));
}

void EventModel::reload() {
    clear();
    QSqlQuery query(getDatabase());
    
    if (query.exec("SELECT * FROM events ORDER BY id DESC")) {        
        while (query.next()) {
            QStandardItem *item = new QStandardItem;
            setItemDataFromQuery(item, query);
            appendRow(item);
        }
        
        sort(0, Qt::DescendingOrder);
    }
}

void EventModel::onItemAdded(qlonglong id) {
    QSqlQuery query(getDatabase());
    query.prepare("SELECT * FROM events WHERE id = ?");
    query.addBindValue(id);
    
    if ((query.exec()) && (query.next())) {
        QStandardItem *item = new QStandardItem;
        setItemDataFromQuery(item, query);
        appendRow(item);
        sort(0, Qt::DescendingOrder);
    }
}

void EventModel::onItemRemoved(qlonglong id) {
    for (int i = 0; i < rowCount(); i++) {
        if (data(i, "id") == id) {
            removeRows(i, 1);
            return;
        }
    }
}

void EventModel::onItemsRemoved(const QString &sourceName) {
    for (int i = rowCount() - 1; i >= 0; i--) {
        if (data(i, "sourceName") == sourceName) {
            removeRows(i, 1);
        }
    }
}

void EventModel::onItemUpdated(qlonglong id) {
    QStandardItem *item = 0;
    
    for (int i = 0; i < rowCount(); i++) {
        if (data(i, "id") == id) {
            item = QStandardItemModel::item(i, 0);
            break;
        }
    }
    
    if (!item) {
        return;
    }
    
    QSqlQuery query(getDatabase());
    query.prepare("SELECT * FROM event WHERE id = ?");
    query.addBindValue(id);
    
    if ((query.exec()) && (query.next())) {
        setItemDataFromQuery(item, query);
        sort(0, Qt::DescendingOrder);
    }
}
