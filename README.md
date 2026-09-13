# SSH Tunnel Manager

A simple Bash-based manager for creating and managing SSH tunnel users on Ubuntu servers.

## Features

* Create SSH tunnel users
* Set account expiration in days
* Check account status
* Extend account expiration
* Delete tunnel users
* Automatically add users to the `tunnelusers` group
* Simple command-line interface

## Requirements

* Ubuntu Server
* OpenSSH Server
* Root or sudo access
* A `tunnelusers` group

## Commands

### Add a user

Create a new tunnel user with a specific number of days of access:

```bash
tunnel-manager add <username> <days>
```

Example:

```bash
tunnel-manager add user1 30
```

The command will:

1. Create the Linux user
2. Ask for a password
3. Add the user to the `tunnelusers` group
4. Set the account expiration date

Example output:

```text
User created successfully!
Username: user1
Expires in: 30 days
```

---

### Check user status

```bash
tunnel-manager status <username>
```

Example:

```bash
tunnel-manager status user1
```

Example output:

```text
User: user1
Status: Active
Expires in: 25 days
```

For an expired account:

```text
User: user1
Status: Expired
Expired: 3 days ago
```

---

### Extend a user's access

```bash
tunnel-manager extend <username> <days>
```

Example:

```bash
tunnel-manager extend user1 10
```

If the user currently has 25 days remaining, 10 days will be added to the existing expiration date.

If the account has already expired, the new expiration will be calculated from the current date.

Example output:

```text
User extended successfully!
New expiration date: 2026-10-08
```

---

### Delete a user

```bash
tunnel-manager delete <username>
```

Example:

```bash
tunnel-manager delete user1
```

Example output:

```text
User deleted successfully.
```

## User Group

Tunnel users are automatically added to:

```text
tunnelusers
```

The SSH server can use this group to apply specific SSH restrictions and forwarding settings to tunnel accounts.

Example SSH configuration:

```text
Match Group tunnelusers
    PermitTTY no
    AllowTcpForwarding yes
    X11Forwarding no
    PermitTunnel no
```

## Security Notes

This project manages Linux accounts used for SSH-based tunneling.

The SSH server configuration should be reviewed before deploying this project on a production server.

Keep the server updated and use strong passwords for tunnel accounts.

## Project Structure

```text
ssh-tunnel-manager/
├── tunnel-manager
├── install.sh
└── README.md
```

## License

This project is provided for educational and administrative purposes.
