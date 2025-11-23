# meta-colorcreator

Yocto/OpenEmbedded layer для сборки Linux образа ColorCreator на базе платы LCPI-PC-T113 (Allwinner T113-S3).

Основан на [meta-lcpi-pc-t113](https://github.com/AndresJejen/meta-lcpi-pc-t113).

## Исправленные проблемы

### ❌ Проблема: Зависание на "booting linux..."
**Причина**: Отсутствовали правильные параметры консоли для UART.

**Решение**:
- Добавлен `recipes-kernel/linux/linux-%.bbappend` с параметрами `console=ttyS0,115200`
- Создана конфигурация машины `conf/machine/lcpi-pc-t113.conf` с `SERIAL_CONSOLES`
- Добавлен U-Boot скрипт `recipes-bsp/u-boot/files/boot.cmd` с правильными bootargs

### ❌ Проблема: Создается сеть "test" вместо "system-t113"
**Причина**: Файл `hostapd_%.bbappend.bak` был отключен (расширение .bak).

**Решение**:
- Переименован в `hostapd_%.bbappend` для активации
- Теперь удаляется дефолтный hostapd.conf с ssid=test
- Используется кастомная конфигурация из wifisetup

## Структура проекта

```
meta-colorcreator/
├── conf/
│   ├── layer.conf                    # Конфигурация layer
│   └── machine/
│       └── lcpi-pc-t113.conf         # Конфигурация машины (UART, bootargs)
├── recipes-bsp/
│   └── u-boot/
│       ├── u-boot_%.bbappend         # Патч для U-Boot
│       └── files/
│           └── boot.cmd              # Скрипт загрузки U-Boot
├── recipes-kernel/
│   └── linux/
│       └── linux-%.bbappend          # Конфигурация kernel (console)
├── recipes-connectivity/
│   ├── hostapd/
│   │   └── hostapd_%.bbappend        # Удаление дефолтного hostapd
│   ├── usb-gadget/
│   │   └── usb-gadget.bb             # USB Gadget ECM для SSH
│   └── wifisetup/
│       └── wifisetup.bb              # Wi-Fi AP/Client с веб-интерфейсом
└── recipes-core/
    └── images/
        └── colorcreator-image.bb     # Основной образ системы
```

## Возможности образа

### Сетевые возможности
- **Wi-Fi Access Point** (по умолчанию):
  - SSID: `system-t113`
  - Пароль: `i8o9p0U8`
  - IP: `192.168.4.1`
  - Веб-интерфейс: http://192.168.4.1
- **Wi-Fi Client**: Подключение к существующей сети
- **USB Gadget ECM**: SSH через USB (192.168.7.2)

### Установленные пакеты
- Драйвер Wi-Fi: `rtl8189ftv`
- Сетевые утилиты: `wpa-supplicant`, `hostapd`, `dnsmasq`, `iw`, `iptables`
- SSH сервер: `dropbear`
- Веб-сервер: `lighttpd` с CGI
- Инструменты разработки: `gcc`, `g++`, `make`, `cmake`
- Системные утилиты: `i2c-tools`, `libgpiod-tools`, `nano`, `htop`

## Сборка образа

### Требования
- Установленный Yocto Dunfell
- meta-lcpi-pc-t113 layer
- meta-sunxi layer (для поддержки Allwinner)

### Добавление layer

```bash
cd <yocto-build-dir>
bitbake-layers add-layer /path/to/meta-colorcreator
```

### Сборка

```bash
# Опционально: использовать machine конфигурацию из этого layer
# export MACHINE=lcpi-pc-t113

# Собрать образ
bitbake colorcreator-image
```

### Результаты сборки
Образ будет в: `tmp/deploy/images/<machine>/colorcreator-image-<machine>.wic`

## Прошивка

### На SD-карту

```bash
sudo dd if=colorcreator-image-<machine>.wic of=/dev/sdX bs=4M status=progress
sync
```

### Через Allwinner Livesuit/PhoenixSuit
Используйте .img файл из директории deploy/images

## Первый запуск

### UART Console
- **Порт**: `/dev/ttyUSB0` (или ttyS0 на плате)
- **Скорость**: 115200
- **Параметры**: 8N1

```bash
sudo minicom -D /dev/ttyUSB0 -b 115200
# или
sudo screen /dev/ttyUSB0 115200
```

### SSH через Wi-Fi AP
```bash
# Подключитесь к Wi-Fi "system-t113" (пароль: i8o9p0U8)
ssh root@192.168.4.1
```

### SSH через USB Gadget
```bash
# Подключите USB кабель к OTG порту платы
ssh root@192.168.7.2
```

## Настройка Wi-Fi

### Веб-интерфейс
Откройте http://192.168.4.1 в браузере после подключения к Wi-Fi AP.

### Командная строка

```bash
# Переключить в режим клиента
wifisetup.sh stop
echo 'CLIENT_SSID="YourNetwork"' >> /etc/colorcreator/wifi.conf
echo 'CLIENT_PASSWORD="password"' >> /etc/colorcreator/wifi.conf
echo 'WIFI_MODE=client' >> /etc/colorcreator/wifi.conf
wifisetup.sh start

# Вернуться в режим AP
sed -i 's/WIFI_MODE=client/WIFI_MODE=ap/' /etc/colorcreator/wifi.conf
wifisetup.sh restart
```

## Устранение неполадок

### Плата зависает на "booting linux"
✅ **ИСПРАВЛЕНО** в текущей версии.

Если проблема сохраняется:
1. Проверьте параметры U-Boot: `printenv bootargs`
2. Должно быть: `console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootwait rw`
3. Проверьте device tree (sun8i-t113-mangopi-dual.dtb)

### Создается сеть "test" вместо "system-t113"
✅ **ИСПРАВЛЕНО** - активирован hostapd_%.bbappend.

Если проблема сохраняется:
1. Проверьте что hostapd_%.bbappend активен (без .bak)
2. Пересоберите образ: `bitbake colorcreator-image -c cleansstate && bitbake colorcreator-image`

### UART не работает
- Убедитесь что используете правильный порт (обычно ttyUSB0)
- Проверьте настройки: 115200 8N1
- Проверьте подключение TX/RX/GND

### Wi-Fi не поднимается
```bash
# Проверить драйвер
lsmod | grep 8189
modprobe 8189fs

# Проверить интерфейс
ip link show wlan0
rfkill unblock wifi

# Перезапустить wifi
/etc/init.d/S99wifi restart
```

## Разработка

### Добавление пакетов
Отредактируйте `recipes-core/images/colorcreator-image.bb`:
```bitbake
IMAGE_INSTALL += "your-package"
```

### Создание собственных recipes
Создайте директорию `recipes-yourapp/yourapp/` и добавьте `.bb` файл.

## Лицензия
MIT

## Контакты
Основан на работе [AndresJejen](https://github.com/AndresJejen/meta-lcpi-pc-t113)
