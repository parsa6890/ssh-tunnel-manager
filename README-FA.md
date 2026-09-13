# SSH Tunnel Manager

[🇬🇧 English](README.md)

یک ابزار ساده مبتنی بر Bash برای ایجاد و مدیریت کاربران SSH Tunnel روی سرورهای Ubuntu.

## نصب

نصب مستقیم SSH Tunnel Manager از GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/parsa6890/ssh-tunnel-manager/main/install.sh | sudo bash
```

Installer به‌صورت خودکار:

1. سیستم‌عامل و OpenSSH Server را بررسی می‌کند
2. در صورت نیاز گروه `tunnelusers` را ایجاد می‌کند
3. ابزار `tunnel-manager` را نصب می‌کند
4. پورت‌های SSH یعنی 22 و 443 را تنظیم می‌کند
5. تنظیمات SSH مربوط به گروه `tunnelusers` را اضافه می‌کند
6. صحت تنظیمات SSH را بررسی می‌کند
7. سرویس SSH را بدون Restart کردن Reload می‌کند

قبل از اعمال تغییرات، یک نسخه پشتیبان از تنظیمات SSH ایجاد می‌شود.

## امکانات

* ایجاد کاربران SSH Tunnel
* تعیین مدت اعتبار حساب بر اساس تعداد روز
* مشاهده وضعیت حساب کاربر
* تمدید مدت اعتبار کاربر
* حذف کاربران Tunnel
* اضافه کردن خودکار کاربران به گروه `tunnelusers`
* رابط خط فرمان ساده

## پیش‌نیازها

* Ubuntu Server
* OpenSSH Server
* دسترسی Root یا sudo

Installer در صورت نبودن گروه `tunnelusers`، آن را به‌صورت خودکار ایجاد می‌کند.

## دستورات

### ایجاد کاربر

ایجاد یک کاربر جدید Tunnel با مدت اعتبار مشخص:

```bash
tunnel-manager add <username> <days>
```

مثال:

```bash
tunnel-manager add user1 30
```

این دستور:

1. کاربر لینوکس را ایجاد می‌کند
2. برای کاربر رمز عبور درخواست می‌کند
3. کاربر را به گروه `tunnelusers` اضافه می‌کند
4. تاریخ انقضای حساب را تنظیم می‌کند

نمونه خروجی:

```text
User created successfully!
Username: user1
Expires in: 30 days
```

---

### مشاهده وضعیت کاربر

```bash
tunnel-manager status <username>
```

مثال:

```bash
tunnel-manager status user1
```

نمونه خروجی:

```text
User: user1
Status: Active
Expires in: 25 days
```

برای حساب منقضی‌شده:

```text
User: user1
Status: Expired
Expired: 3 days ago
```

---

### تمدید اعتبار کاربر

```bash
tunnel-manager extend <username> <days>
```

مثال:

```bash
tunnel-manager extend user1 10
```

اگر کاربر در حال حاضر 25 روز اعتبار داشته باشد، 10 روز به تاریخ انقضای فعلی او اضافه می‌شود.

اگر حساب قبلاً منقضی شده باشد، تاریخ انقضای جدید از تاریخ فعلی محاسبه خواهد شد.

نمونه خروجی:

```text
User extended successfully!
New expiration date: 2026-10-08
```

---

### حذف کاربر

```bash
tunnel-manager delete <username>
```

مثال:

```bash
tunnel-manager delete user1
```

نمونه خروجی:

```text
User deleted successfully.
```

## گروه کاربران

کاربران Tunnel به‌صورت خودکار به گروه زیر اضافه می‌شوند:

```text
tunnelusers
```

سرور SSH می‌تواند از این گروه برای اعمال تنظیمات و محدودیت‌های اختصاصی SSH و قابلیت‌های Forwarding استفاده کند.

نمونه تنظیمات SSH:

```text
Match Group tunnelusers
    PermitTTY no
    AllowTcpForwarding yes
    X11Forwarding no
    PermitTunnel no
```

## نکات امنیتی

این پروژه حساب‌های لینوکس مورد استفاده برای SSH-based tunneling را مدیریت می‌کند.

قبل از استفاده از این پروژه روی یک سرور Production، تنظیمات SSH Server را بررسی کنید.

سرور را به‌روز نگه دارید و برای حساب‌های Tunnel از رمزهای عبور قوی استفاده کنید.

## ساختار پروژه

```text
ssh-tunnel-manager/
├── tunnel-manager
├── install.sh
├── README.md
└── README-FA.md
```

## لایسنس

این پروژه برای اهداف آموزشی و مدیریتی ارائه شده است.
