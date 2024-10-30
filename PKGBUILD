# Maintainer: Filippo Tobias <filippotobias@gmail.com>

pkgname=ez-volume
pkgver=1.0.10
pkgrel=1
pkgdesc="Installs ez-volume.sh and creates a systemd service to run it"
arch=('any')
license=('custom')
install="${pkgname}.install"

source=('ez-volume.sh' 'ez-volume.service')
sha256sums=('SKIP' 'SKIP')  # Replace with actual checksums if needed

package() {
  # Install the script
  install -Dm755 "$srcdir/ez-volume.sh" "$pkgdir/usr/local/bin/ez-volume.sh"

  # Install the systemd service
  install -Dm644 "$srcdir/ez-volume.service" "$pkgdir/etc/systemd/user/ez-volume.service"
}
