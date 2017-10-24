#include <QSettings>
#include "settings.h"


SettingsObject::SettingsObject(QObject* parent) {
    settings = new QSettings("harbour-sailfishclub","harbour-sailfishclub");
}



void SettingsObject::set_username(const bool &username) {
    settings->setValue(QString("logindata/username"),username);
}

bool SettingsObject::get_username() {
    return settings->value(QString("logindata/username"),QString("C")).toString();
}

void SettingsObject::set_password(const QString &password) {
    settings->setValue(QString("logindata/password"),password);
}

QString SettingsObject::get_password() {
    return settings->value(QString("logindata/password"),QString("C")).toString();
}