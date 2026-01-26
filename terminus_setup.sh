# Why Tailscale feels “too easy”

- No port forwarding
- No public IPs
- No DNS setup
- No certificates
- Works behind CGNAT
- Works even if your home IP changes
- Uses WireGuard under the hood
- You just install + login.

# Exact Setup (WSL2 + iPhone + Termius)

## 1️⃣ Install Tailscale in WSL2

Inside Ubuntu (WSL2):

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Start it:

```bash
sudo tailscaled
sudo tailscale up
```

sudo tailscaled	✅
sudo tailscale up	✅

You’ll see:

```
To authenticate, visit:
https://login.tailscale.com/a/xxxx
```

Open link → sign in with Google / GitHub / Microsoft.

✅ Done.

## 2️⃣ Confirm WSL2 got a Tailscale IP

```bash
tailscale ip -4
```

Example:

```
100.101.102.103
```

That IP is private, stable, and reachable from anywhere.

## 3️⃣ Install Tailscale on iPhone

App Store → Tailscale

Login with same account

Toggle Connect

Your iPhone is now on the same private network as WSL2.

## 4️⃣ Enable SSH in WSL2 (if not already)

```bash
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

Test locally:

```bash
ssh localhost
```

## 5️⃣ Add Host in Termius (iOS)

In Termius → Hosts → New Host:

| Field | Value |
| --- | --- |
| Address | 100.101.102.103 (Tailscale IP) |
| Port | 22 |
| Username | your Linux user |
| Auth | SSH key (recommended) |

Tap connect → you’re in.

## 🧠 Even better (Tailscale Magic DNS)

Instead of IPs:

Enable Magic DNS in Tailscale admin console.

Then you can use:

```
wsl2-lohit.tailnet-name.ts.net
```

Termius works perfectly with this.

# Security Model (why it’s safe)

- End-to-end encrypted (WireGuard)
- Devices must be logged into your account
- No public exposure
- No SSH scans
- Can revoke devices instantly

This is much safer than public SSH.

# How it compares to Cloudflare Tunnel (honest take)

| Feature | Tailscale | Cloudflare Tunnel |
| --- | --- | --- |
| Setup | 10 mins | 30–60 mins |
| Mental load | Very low | Medium |
| SSH UX | Excellent | Excellent |
| Domains | No | Yes |
| Zero Trust policies | Basic | Advanced |
| Forget-it-exists factor | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

👉 For personal dev access → Tailscale wins

👉 For customer / multi-user access → Cloudflare wins

# My recommendation for you

Given:

- You want Termius on iPhone
- You’re accessing your own WSL2
- You already have enough infra complexity 😄

👉 Use Tailscale for daily work

👉 Keep Cloudflare Tunnel for prod / demos / customer access

Many senior infra folks do exactly this split.

If you want next-level polish, I can help you:

- Auto-start Tailscale with WSL
- Lock SSH to Tailscale interface only
- Auto-attach Zellij on SSH login
- Use Tailscale SSH instead of OpenSSH

Just say the word.
