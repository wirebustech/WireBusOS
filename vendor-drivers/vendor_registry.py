#!/usr/bin/env python3
"""
WireBusOS Vendor Extension SDK & CLI Manager
Usage:
  python3 vendor-drivers/vendor_registry.py list
  python3 vendor-drivers/vendor_registry.py add --name "HydroTech" --category "hydro" --protocol "ModbusTCP"
"""

import sys
import os
import json
import argparse

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_DIR = os.path.dirname(SCRIPT_DIR)
REGISTRY_FILE = os.path.join(REPO_DIR, "config", "vendor_registers.json")
TEMPLATE_FILE = os.path.join(SCRIPT_DIR, "templates", "custom_vendor_template.py")

def load_registry():
    if os.path.exists(REGISTRY_FILE):
        with open(REGISTRY_FILE, "r") as f:
            return json.load(f)
    return {"system": "WireBusOS Registry", "vendors": []}

def save_registry(data):
    with open(REGISTRY_FILE, "w") as f:
        json.dump(data, f, indent=2)

def list_vendors():
    reg = load_registry()
    print("================================================----------------------")
    print(f"⚡ WireBusOS Vendor Registry — Total Registered Vendors: {len(reg.get('vendors', []))}")
    print("================================================----------------------")
    print(f"{'VENDOR NAME':<26} | {'CATEGORY':<10} | {'ECOSYSTEM / PROTOCOL'}")
    print("----------------------------------------------------------------------")
    for v in reg.get("vendors", []):
        cat = v.get("category", "General")
        print(f"{v['vendor']:<26} | {cat:<10} | {v['ecosystem']}")
    print("----------------------------------------------------------------------")

def add_vendor(name, category, protocol, devices):
    reg = load_registry()
    
    # Check if vendor exists
    for v in reg.get("vendors", []):
        if v["vendor"].lower() == name.lower():
            print(f"ℹ️ Vendor '{name}' already registered.")
            break
    else:
        new_vendor = {
            "vendor": name,
            "category": category,
            "ecosystem": f"{protocol} Integration",
            "devices": devices.split(",") if devices else [f"{name} Device"],
            "registers": [
                { "id": "40001", "name": f"{name}_Active_Power", "type": "UINT16", "unit": "kW", "desc": "Total Output Power" },
                { "id": "40002", "name": f"{name}_Status", "type": "UINT16", "unit": "enum", "desc": "0=Offline, 1=Operational" }
            ]
        }
        reg["vendors"].append(new_vendor)
        save_registry(reg)

    # Scaffolding new driver file
    safe_filename = name.lower().replace(" ", "_").replace("-", "_") + "_driver.py"
    driver_path = os.path.join(SCRIPT_DIR, safe_filename)

    if os.path.exists(TEMPLATE_FILE):
        with open(TEMPLATE_FILE, "r") as f:
            tmpl = f.read()
        code = tmpl.replace("__VENDOR_NAME__", name)\
                   .replace("__VENDOR_CATEGORY__", category)\
                   .replace("__VENDOR_PROTOCOL__", protocol)
        with open(driver_path, "w") as f:
            f.write(code)
        os.chmod(driver_path, 0o755)
        print(f"✅ Registered Vendor '{name}' in config/vendor_registers.json")
        print(f"📄 Created Driver Boilerplate: vendor-drivers/{safe_filename}")

def main():
    parser = argparse.ArgumentParser(description="WireBusOS Vendor Extension CLI Manager")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("list", help="List all registered vendors")
    
    add_parser = subparsers.add_parser("add", help="Add a new custom vendor driver")
    add_parser.add_argument("--name", required=True, help="Vendor Name (e.g. HydroTech)")
    add_parser.add_argument("--category", default="solar", help="Category (solar/wind/hydro/storage/ev)")
    add_parser.add_argument("--protocol", default="ModbusTCP", help="Protocol (ModbusTCP/CANbus/REST_API/S7comm)")
    add_parser.add_argument("--devices", default="", help="Comma separated devices")

    args = parser.parse_args()

    if args.command == "list":
        list_vendors()
    elif args.command == "add":
        add_vendor(args.name, args.category, args.protocol, args.devices)
    else:
        list_vendors()

if __name__ == "__main__":
    main()
