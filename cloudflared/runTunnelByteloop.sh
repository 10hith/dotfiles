#!/bin/bash
cloudflared --config ~/.cloudflared/config.yml --origincert ~/.cloudflared/cert_byteloop.pem tunnel run 
