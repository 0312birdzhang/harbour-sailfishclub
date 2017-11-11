# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-sailfishclub

# >> macros
%define __requires_exclude ^libc.so.6(GLIBC_2.11)|libjpeg.so.62|libjpeg.so.62(LIBJPEG_6.2)|libpython3.4m.so.1.0|libtiff.so.5.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    My Sailfish OS Application
Version:    0.1.0
Release:    1
Group:      Qt/Qt
License:    LICENSE
URL:        https://sailfishos.club/
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-sailfishclub.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.3.0
Requires:   python3-pynodebb >= 0.0.14
Requires:   python3-crypto
Requires:   mapplauncherd-booster-silica-qt5
Requires:   nemo-qml-plugin-thumbnailer-qt5
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Short description of my Sailfish OS Application


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
