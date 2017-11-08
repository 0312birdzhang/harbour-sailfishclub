#ifndef SETTINGS
#define SETTINGS

#include<QSettings>
#include<QString>

class SettingsObject: public QObject {
    Q_OBJECT
private:
    QSettings* settings;
public:
    explicit SettingsObject();
    Q_INVOKABLE void set_username(const QString &username);
    Q_INVOKABLE QString get_username();
    Q_INVOKABLE void set_password(const QString &password);
    Q_INVOKABLE QString get_password();
    Q_INVOKABLE void set_pagesize(const quint16 &pagesize);
    Q_INVOKABLE int get_pagesize();

};

#endif // SETTINGS
