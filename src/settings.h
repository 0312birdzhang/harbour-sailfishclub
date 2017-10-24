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
};

#endif // SETTINGS
