# TOOLS-INVENTORY — catalogo VIVO de herramientas de este Kali
# Generado: 2026-10-06 20:26 UTC — regenerar: python3 tools-inventory.py

## Como usarlo (para el agente)
- Antes de elegir herramienta en cualquier fase, consulta ESTE archivo.
- Usa solo las marcadas [OK] (instaladas). Las [--] no existen en el sistema.
- Escribe la SINTAXIS COMPLETA con flags; jamas solo el nombre de la herramienta.
- Toda salida va a artefacto con ruta absoluta (regla nonzero del review).
- Si ninguna herramienta [OK] sirve para el paso, NO instales nada: anota en LEARNINGS.md (pendiente) que herramienta faltaria y sugiere el paquete.

| Estado | Herramienta | Para que |
|---|---|---|

## Recon de superficie / subdominios

| [OK] | `subfinder` | enumeracion pasiva de subdominios |
| [OK] | `amass` | enum. pasiva+activa de subdominios ( Intel ) |
| [--] | `assetfinder` | subdominios rapidos desde fuentes pasivas |
| [--] | `sublist3r` | subdominios (clasico) |
| [--] | `massdns` | resolucion masiva de DNS |
| [--] | `dnsx` | resolucion/verificacion DNS con salida limpia |
| [OK] | `dnsrecon` | enumeracion DNS (SRV/AXFR/zonas) |
| [OK] | `theHarvester` | emails, hosts y nombres desde fuentes OSINT |
| [--] | `naabu` | sondeo de puertos rapido (salida para httpx) |
| [OK] | `nmap` | sondeo de puertos/servicios (el canon) |
| [OK] | `masscan` | sondeo de puertos a velocidad de Internet |

## Sondeo HTTP / fingerprint

| [OK] | `httpx` | sondeo HTTP multi-puerto con titulos/tech (basico del hackbot) |
| [OK] | `whatweb` | fingerprint de tecnologias web |
| [--] | `wappalyzer` | fingerprint (CLI node) |
| [--] | `httprobe` | verifica hosts con HTTP/HTTPS |
| [--] | `unfurl` | extrae/analiza URLs y parametros |
| [--] | `anew` | anade lineas nuevas a archivos (dedup) |

## Descubrimiento de endpoints y URLs

| [--] | `waymore` | historico JS+URLs de Wayback y mas |
| [--] | `gau` | URLs historicas (getallurls) |
| [--] | `waybackurls` | URLs del Wayback Machine |
| [--] | `hakrawler` | spider en Go, recoge URLs/forms/JS |
| [OK] | `katana` | spider moderno (projectdiscovery) |
| [--] | `paramspider` | parametros historicos de URLs |
| [OK] | `arjun` | descubridor de parametros ocultos |
| [--] | `linkfinder` | endpoints en JS (regex) |
| [--] | `secretfinder` | secretos en JS (regex) |
| [--] | `jsluice` | endpoints/secretos en JS (el de js-analyze) |

## Fuerza bruta de contenido

| [OK] | `ffuf` | fuzzing web rapido (el del hackbot) |
| [OK] | `feroxbuster` | fuzzing recursivo con extraccion de enlaces |
| [OK] | `gobuster` | fuerza bruta de dirs/DNS/vhosts |
| [OK] | `dirb` | fuerza bruta clasica |
| [OK] | `wfuzz` | fuzzing generalista por payloads |

## Deteccion de vulnerabilidades

| [OK] | `nuclei` | plantillas de vulns por objetivo (el del hackbot) |
| [OK] | `nikto` | escaner web clasico de misconfigs |
| [OK] | `sqlmap` | explotacion/det SQLi automatizada |
| [--] | `dalfox` | XSS reflejado/almacenado moderno |
| [--] | `xsstrike` | XSS con analisis de WAF |
| [--] | `testssl` | auditoria SSL/TLS |
| [OK] | `sslyze` | analisis SSL/TLS programable |
| [OK] | `sslscan` | recon SSL rapido |
| [OK] | `wpscan` | WordPress: vulns, plugins, usuarios |
| [--] | `nuclei-templates` | repo de templates de nuclei (si esta clonado) |

## Analisis de APIs

| [--] | `grpcurl` | llama endpoints gRPC desde CLI |
| [--] | `websocat` | cliente WebSocket para APIs async |
| [--] | `postman/newman` | colecciones de API automatizadas |
| [--] | `openapi-spec-validator` | valida spec OpenAPI |

## Auth / credenciales / hashes

| [OK] | `hashcat` | cracking de hashes (GPU) |
| [OK] | `john` | cracking de hashes (CPU) |
| [OK] | `hydra` | fuerza bruta de logins por protocolo |
| [--] | `crackmapexec` | ofensiva SMB/WinRM/LDAP (CME) |
| [OK] | `netexec` | sucesor moderno de crackmapexec |

## Red / trafico / pivotaje

| [OK] | `tcpdump` | captura de paquetes |
| [OK] | `wireshark` | analisis de trafico (GUI) |
| [--] | `impacket` | suite de protocolos Windows (python) |
| [OK] | `responder` | envenenamiento LLMNR/NBT-NS |
| [OK] | `enum4linux` | enumeracion SMB de objetivos *nix |
| [OK] | `smbclient` | cliente SMB para probar shares |
| [OK] | `snmpwalk` | consulta SNMP |

## Explotacion y post

| [OK] | `msfconsole` | Metasploit Framework |
| [OK] | `searchsploit` | busca exploits en Exploit-DB |
| [OK] | `msfvenom` | genera payloads |

## Secretos / repos / configs

| [--] | `trufflehog` | secretos en repos e historia git |
| [--] | `gitleaks` | secretos en codigo (SAST local) |
| [OK] | `jq` | procesa JSON (imprescindible) |
| [--] | `yq` | procesa YAML/XML |
| [OK] | `git` | clonar/analizar repos expuestos (.git) |

## Utilidades de shell del hackbot

| [OK] | `curl` | peticiones HTTP manual (el del hackbot) |
| [OK] | `wget` | descargas |
| [OK] | `jq` | filtrado de salidas JSON a artefactos |
| [--] | `pup` | extrae datos de HTML |
| [--] | `htmlq` | consultas CSS sobre HTML |

**Resumen:** 39 instaladas, 32 no disponibles.

> Nota del operador: tras `sudo apt install ...` o `go install ...`,
> regenera con: `python3 ~/ProjectMajorTom/tools-inventory.py`