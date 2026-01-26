#!/bin/bash
cloudflared --config ~/.cloudflared/config_err.yml --origincert ~/.cloudflared/cert_err.pem tunnel run 13a8ddcf-975a-41ee-ac5c-79f716adf63f
