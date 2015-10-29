/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
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

#ifndef EVENTMODEL_H
#define EVENTMODEL_H

#include <QStandardItemModel>

class EventModel : public QStandardItemModel
{
    Q_OBJECT
        
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        IconRole,
        TitleRole,
        BodyRole,
        ImageListRole,
        TimestampRole,
        TimestampStringRole,
        FooterRole,
        VideoRole,
        UrlRole,
        ActionRole,
        SourceNameRole,
        SourceDisplayNameRole
    };
    
    explicit EventModel(QObject *parent = 0);
    
#if QT_VERSION >= 0x050000
    QHash<int, QByteArray> roleNames() const;
#endif
        
public Q_SLOTS:
    QVariant data(int row, const QByteArray &roleName) const;
    
    void reload();
    
private Q_SLOTS:
    void onItemAdded(qlonglong id);
    void onItemRemoved(qlonglong id);
    void onItemsRemoved(const QString &sourceName);
    void onItemUpdated(qlonglong id);

private:
    QHash<int, QByteArray> m_roles;
};

#endif // EVENTMODEL_H
