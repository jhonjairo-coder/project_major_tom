#!/usr/bin/env python3
# tools-inventory.py — genera tools-inventory.md: catalogo VIVO de herramientas del Kali
# Los agentes lo consultan para elegir la mejor herramienta INSTALADA en cada fase.
# Regenerar tras instalar cosas nuevas: python3 tools-inventory.py

import shutil, datetime

CATS = [
 ("Recon de superficie / subdominios", [
  ("subfinder","enumeracion pasiva de subdominios"),
  ("amass","enum. pasiva+activa de subdominios ( Intel )"),
  ("assetfinder","subdominios rapidos desde fuentes pasivas"),
  ("sublist3r","subdominios (clasico)"),
  ("massdns","resolucion masiva de DNS"),
  ("dnsx","resolucion/verificacion DNS con salida limpia"),
  ("dnsrecon","enumeracion DNS (SRV/AXFR/zonas)"),
  ("theHarvester","emails, hosts y nombres desde fuentes OSINT"),
  ("naabu","sondeo de puertos rapido (salida para httpx)"),
  ("nmap","sondeo de puertos/servicios (el canon)"),
  ("masscan","sondeo de puertos a velocidad de Internet"),
 ]),
 ("Sondeo HTTP / fingerprint", [
  ("httpx","sondeo HTTP multi-puerto con titulos/tech (basico del hackbot)"),
  ("whatweb","fingerprint de tecnologias web"),
  ("wappalyzer","fingerprint (CLI node)"),
  ("httprobe","verifica hosts con HTTP/HTTPS"),
  ("unfurl","extrae/analiza URLs y parametros"),
  ("anew","anade lineas nuevas a archivos (dedup)"),
 ]),
 ("Descubrimiento de endpoints y URLs", [
  ("waymore","historico JS+URLs de Wayback y mas"),
  ("gau","URLs historicas (getallurls)"),
  ("waybackurls","URLs del Wayback Machine"),
  ("hakrawler","spider en Go, recoge URLs/forms/JS"),
  ("katana","spider moderno (projectdiscovery)"),
  ("paramspider","parametros historicos de URLs"),
  ("arjun","descubridor de parametros ocultos"),
  ("linkfinder","endpoints en JS (regex)"),
  ("secretfinder","secretos en JS (regex)"),
  ("jsluice","endpoints/secretos en JS (el de js-analyze)"),
 ]),
 ("Fuerza bruta de contenido", [
  ("ffuf","fuzzing web rapido (el del hackbot)"),
  ("feroxbuster","fuzzing recursivo con extraccion de enlaces"),
  ("gobuster","fuerza bruta de dirs/DNS/vhosts"),
  ("dirb","fuerza bruta clasica"),
  ("wfuzz","fuzzing generalista por payloads"),
 ]),
 ("Deteccion de vulnerabilidades", [
  ("nuclei","plantillas de vulns por objetivo (el del hackbot)"),
  ("nikto","escaner web clasico de misconfigs"),
  ("sqlmap","explotacion/det SQLi automatizada"),
  ("dalfox","XSS reflejado/almacenado moderno"),
  ("xsstrike","XSS con analisis de WAF"),
  ("testssl","auditoria SSL/TLS"),
  ("sslyze","analisis SSL/TLS programable"),
  ("sslscan","recon SSL rapido"),
  ("wpscan","WordPress: vulns, plugins, usuarios"),
  ("nuclei-templates","repo de templates de nuclei (si esta clonado)"),
 ]),
 ("Analisis de APIs", [
  ("grpcurl","llama endpoints gRPC desde CLI"),
  ("websocat","cliente WebSocket para APIs async"),
  ("postman/newman","colecciones de API automatizadas"),
  ("openapi-spec-validator","valida spec OpenAPI"),
 ]),
 ("Auth / credenciales / hashes", [
  ("hashcat","cracking de hashes (GPU)"),
  ("john","cracking de hashes (CPU)"),
  ("hydra","fuerza bruta de logins por protocolo"),
  ("crackmapexec","ofensiva SMB/WinRM/LDAP (CME)"),
  ("netexec","sucesor moderno de crackmapexec"),
 ]),
 ("Red / trafico / pivotaje", [
  ("tcpdump","captura de paquetes"),
  ("wireshark","analisis de trafico (GUI)"),
  ("impacket","suite de protocolos Windows (python)"),
  ("responder","envenenamiento LLMNR/NBT-NS"),
  ("enum4linux","enumeracion SMB de objetivos *nix"),
  ("smbclient","cliente SMB para probar shares"),
  ("snmpwalk","consulta SNMP"),
 ]),
 ("Explotacion y post", [
  ("msfconsole","Metasploit Framework"),
  ("searchsploit","busca exploits en Exploit-DB"),
  ("msfvenom","genera payloads"),
 ]),
 ("Secretos / repos / configs", [
  ("trufflehog","secretos en repos e historia git"),
  ("gitleaks","secretos en codigo (SAST local)"),
  ("jq","procesa JSON (imprescindible)"),
  ("yq","procesa YAML/XML"),
  ("git","clonar/analizar repos expuestos (.git)"),
 ]),
 ("Utilidades de shell del hackbot", [
  ("curl","peticiones HTTP manual (el del hackbot)"),
  ("wget","descargas"),
  ("jq","filtrado de salidas JSON a artefactos"),
  ("pup","extrae datos de HTML"),
  ("htmlq","consultas CSS sobre HTML"),
 ]),
]

def have(t):
    return shutil.which(t) is not None

ok = miss = 0
lines = ["# TOOLS-INVENTORY — catalogo VIVO de herramientas de este Kali",
 f"# Generado: {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')} — regenerar: python3 tools-inventory.py",
 "",
 "## Como usarlo (para el agente)",
 "- Antes de elegir herramienta en cualquier fase, consulta ESTE archivo.",
 "- Usa solo las marcadas [OK] (instaladas). Las [--] no existen en el sistema.",
 "- Escribe la SINTAXIS COMPLETA con flags; jamas solo el nombre de la herramienta.",
 "- Toda salida va a artefacto con ruta absoluta (regla nonzero del review).",
 "- Si ninguna herramienta [OK] sirve para el paso, NO instales nada: anota en LEARNINGS.md (pendiente) que herramienta faltaria y sugiere el paquete.",
 "",
 "| Estado | Herramienta | Para que |", "|---|---|---|"]
for cat, tools in CATS:
    lines.append(f"\n## {cat}\n")
    for name, desc in tools:
        if have(name):
            lines.append(f"| [OK] | `{name}` | {desc} |"); ok += 1
        else:
            lines.append(f"| [--] | `{name}` | {desc} |"); miss += 1

lines += ["", f"**Resumen:** {ok} instaladas, {miss} no disponibles.",
 "", "> Nota del operador: tras `sudo apt install ...` o `go install ...`,",
 "> regenera con: `python3 ~/ProjectMajorTom/tools-inventory.py`"]

open("tools-inventory.md", "w", encoding="utf-8").write("\n".join(lines))
print(f"OK -> tools-inventory.md | {ok} instaladas, {miss} no disponibles")
