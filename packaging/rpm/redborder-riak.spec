%undefine __brp_mangle_shebangs

Name: redborder-riak
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Package for redborder riak init scripts and configuration

License: AGPL 3.0
URL: https://github.com/redBorder/redborder-riak
Source0: %{name}-%{version}.tar.gz

Requires: riak riak-cs stanchion

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/etc/riak
mkdir -p %{buildroot}/usr/lib/redborder/bin
mkdir -p %{buildroot}/usr/lib/redborder/scripts
install -D -m 0644 resources/riak.service %{buildroot}/usr/lib/systemd/system/riak.service
install -D -m 0644 resources/riak-cs.service %{buildroot}/usr/lib/systemd/system/riak-cs.service
install -D -m 0644 resources/stanchion.service %{buildroot}/usr/lib/systemd/system/stanchion.service
install -D -m 0755 resources/rb_create_buckets.rb %{buildroot}/usr/lib/redborder/scripts/rb_create_buckets.rb
install -D -m 0755 resources/rb_s3_user.rb %{buildroot}/usr/lib/redborder/scripts/rb_s3_user.rb

%pre

%post
/usr/lib/redborder/bin/rb_rubywrapper.sh -c
systemctl daemon-reload

%postun
/usr/lib/redborder/bin/rb_rubywrapper.sh -c

%files
%defattr(0644,root,root)
/usr/lib/systemd/system/riak.service
/usr/lib/systemd/system/riak-cs.service
/usr/lib/systemd/system/stanchion.service
%defattr(0755,root,root)
/usr/lib/redborder/scripts/rb_create_buckets.rb
/usr/lib/redborder/scripts/rb_s3_user.rb
%doc

%changelog
* Mon Feb 20 2017 Carlos J. Mateos <cjmateos@redborder.com> - 0.0.1
- first spec version
