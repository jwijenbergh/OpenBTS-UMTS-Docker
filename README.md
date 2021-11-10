# OpenBTS-UMTS-Docker
Docker configuration to quickly setup an UMTS network with an SDR supported by OpenBTS-UMTS using UHD.

# Dependencies

- Docker
- Docker-compose
- Tmux for easy starting with a script

# Usage

- Connect your SDR using the USB interface. Currently tested with an Ettus USRP B210
- Then to start a network configured with a phone in the subscriber registry:
```bash
./starttmux.sh NAME IMSI MSISDN KI
```
- (Optional) To have multiple phones registered, you can modify the tmux helper script or add more phones using:
```bash
docker-compose exec openbts-umts /OpenBTS-UMTS/NodeManager/nmcli.py sipauthserve subscribers create NAME IMSI MSISDN KI
```
