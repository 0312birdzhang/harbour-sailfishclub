# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-sailfishclub

# >> macros
%define __requires_exclude ^libc.so.6(GLIBC_2.11)|libjpeg.so.62|libjpeg.so.62(LIBJPEG_6.2)|libtiff.so.5.*|libQt5Qml.so.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    SailfishClub client for Sailfish OS
Version:    0.3.6
Release:    2
Group:      Qt/Qt
License:    GPLv3
URL:        https://sailfishos.club/
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-sailfishclub.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.3.0
Requires:   mapplauncherd-booster-silica-qt5
#Requires:   nemo-qml-plugin-thumbnailer-qt5
Requires:   qt5-qtsvg-plugin-imageformat-svg
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Svg)

BuildRequires:  desktop-file-utils

%description
SailfishClub client for Sailfish OS
SailfishClub is an unofficial Chinese community
旗鱼俱乐部，一个非官方中文论坛

%prep
%setup -q -n %{name}-%{version}


# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop


%files

%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
