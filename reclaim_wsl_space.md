# Reclaim Disk Space from WSL2 + Docker

> Reference: https://superuser.com/questions/1606213/how-do-i-get-back-unused-disk-space-from-ubuntu-on-wsl2

---

## ⚠️ Pre-Flight Checklist — Do This Before Running Anything

1. **Run the disk usage script first** so you have a before-snapshot to compare against.
2. **Close all open terminals** connected to WSL (Ubuntu, any distro).
3. **Stop any running Docker containers** — check with `docker ps`. Make sure nothing important is mid-process.
4. **Commit / push any work in progress** in WSL — shutting down WSL kills running processes.
5. **Note your Docker images you want to keep** — `docker system prune -a` removes *all* unused images, not just dangling ones. Run `docker images` and confirm there's nothing you'd miss.
6. **Do not run the VHD optimize steps while WSL or Docker Desktop is running** — the VHDX files must be fully released or the optimize command will fail or corrupt them.
7. **Run PowerShell as Administrator** for the `optimize-vhd` steps.

---

## Step 1 — Clean Up Docker (while Docker Desktop is still running)

Run these in a normal terminal (PowerShell or CMD) before shutting anything down:

```powershell
# Remove all unused images, stopped containers, unused networks, and volumes
docker system prune -a --volumes --force
```

If you prefer to be more selective, use these individually:

```powershell
# Remove only untagged/dangling images
docker image prune --filter "dangling=true" --force

# Remove stopped containers
docker container prune --force

# Remove volumes not attached to any container
docker volume prune --force
```

To remove only volumes that haven't been used in 90+ days, run this in a WSL/bash terminal:

```bash
docker volume ls -qf dangling=true | while read volume; do
  created=$(docker volume inspect "$volume" --format '{{.CreatedAt}}')
  created_epoch=$(date -d "$created" +%s)
  now=$(date +%s)
  diff_days=$(( (now - created_epoch) / 86400 ))
  if [ $diff_days -gt 90 ]; then
    echo "Removing volume: $volume (unused for more than 3 months)"
    docker volume rm "$volume"
  fi
done
```

---

## Step 2 — Shut Everything Down

```powershell
# Shut down all WSL distros
wsl --shutdown
```

Then **quit Docker Desktop** from the system tray (right-click → Quit Docker Desktop). Wait until it fully exits — the whale icon disappears from the tray.

Confirm everything is stopped:

```powershell
wsl --list --running   # should show no running distros
```

---

## Step 3 — Compact the WSL Ubuntu VHD (PowerShell as Admin)

```powershell
# Navigate to the Ubuntu WSL disk folder
cd "$env:LOCALAPPDATA\Packages\CanonicalGroupLimited.Ubuntu20.04onWindows_79rhkp1fndgsc\LocalState"

# Compact the ext4 disk image
Optimize-VHD -Path .\ext4.vhdx -Mode Full
```

> This can take several minutes depending on how much free space is inside the VHD.

---

## Step 4 — Compact the Docker Data VHD (PowerShell as Admin)

```powershell
# Navigate to the Docker WSL disk folder
cd "$env:LOCALAPPDATA\Docker\wsl\disk"

# Compact the Docker data image
Optimize-VHD -Path .\docker_data.vhdx -Mode Full
```

> **Known paths on this machine:**
> - WSL Ubuntu: `C:\Users\lohith\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu20.04onWindows_79rhkp1fndgsc\LocalState\ext4.vhdx`
> - Docker Data: `C:\Users\lohith\AppData\Local\Docker\wsl\disk\docker_data.vhdx`

---

## Step 5 — Verify the Results

After everything completes, restart Docker Desktop and WSL, then run the disk usage script again to compare the before/after snapshot.

```powershell
# Check Drive C free space quickly
Get-PSDrive C | Select-Object Used, Free
```

---

## Quick Reference — Full Sequence

```
1. docker system prune -a --volumes --force
2. wsl --shutdown
3. Quit Docker Desktop from tray
4. [Admin PowerShell] Optimize-VHD on ext4.vhdx
5. [Admin PowerShell] Optimize-VHD on docker_data.vhdx
6. Run disk usage script to confirm savings
```
