# Cloudflared Tunnel Setup

Follow these steps to set up Cloudflared tunnels:

1. **Download the latest cloudflared package for Linux (amd64 architecture):**
    ```bash
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
    ```

2. **Install the downloaded cloudflared package using dpkg:**
    ```bash
    sudo dpkg -i cloudflared.deb
    ```

3. **Authenticate cloudflared with your Cloudflare account:**
    ```bash
    cloudflared tunnel login
    ```

4. **Create a new Cloudflare tunnel named "10hithTest":**
    ```bash
    cloudflared tunnel create 10hithTest
    ```

5. **Route DNS requests for `waba.byteloop.ai` to the tunnel with UUID `50dd9498-fa0f-4084-8d7e-15ca56060c3e`:**
    ```bash
    cloudflared tunnel route dns [TUNNELNAME](setup.md:10) waba.byteloop.ai
    ```

6. **Run Ordelo:**
    ```bash
    cloudflared --config [config.yml](config.yml:15) --origincert [cert_byteloop.pem](cert_byteloop.pem:16) tunnel run 
    ```

---

### Another Account Setup

1. **Create a new tunnel named "err":**
    ```bash
    cloudflared --origincert [cert_err.pem](cert_err.pem:20) tunnel create err
    ```
    <!-- /home/basal/.cloudflared/13a8ddcf-975a-41ee-ac5c-79f716adf63f.json -->

2. **Create a route to DNS:**
    ```bash
    cloudflared --origincert [cert_err.pem](cert_err.pem:23) tunnel route dns 13a8ddcf-975a-41ee-ac5c-79f716adf63f err.ever-ready.ai
    ```

3. **Run the tunnel:**
    ```bash
    cloudflared --config [config_err.yml](config_err.yml:26) --origincert [cert_err.pem](cert_err.pem:26) tunnel run 13a8ddcf-975a-41ee-ac5c-79f716adf63f