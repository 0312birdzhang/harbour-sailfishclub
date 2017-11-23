#include <QSettings>
#include "settings.h"


SettingsObject::SettingsObject() {
    settings = new QSettings("harbour-sailfishclub","harbour-sailfishclub");
}



void SettingsObject::set_username(const QString &username) {
    settings->setValue(QString("logindata/username"),username);
}

QString SettingsObject::get_username() {
    return settings->value(QString("logindata/username"),QString("")).toString();
}

void SettingsObject::set_password(const QString &password) {
    settings->setValue(QString("logindata/password"),password);
}

QString SettingsObject::get_password() {
    return settings->value(QString("logindata/password"),QString("")).toString();
}

void SettingsObject::set_uid(const int &uid) {
    settings->setValue(QString("settings/uid"),uid);
}

int SettingsObject::get_uid() {
    return settings->value(QString("settings/uid"),0).toInt();
}

void SettingsObject::set_token(const QString &token) {
    settings->setValue(QString("logindata/token"),token);
}

QString SettingsObject::get_token() {
    return settings->value(QString("logindata/token"),QString("")).toString();
}

void SettingsObject::set_pagesize(const int &pagesize) {
    settings->setValue(QString("settings/pagesize"),pagesize);
}

int SettingsObject::get_pagesize() {
    return settings->value(QString("settings/pagesize"),20).toInt();
}
