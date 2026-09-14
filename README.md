# Logicore Portal — Lucee

This repository is the **Lucee/CFML port** of [`greywalks/Logicore-Portal`](https://github.com/greywalks/Logicore-Portal). The original Flask/Python repository is intentionally left unchanged.

## Runtime

- **Lucee 7** via CommandBox
- **CFML** application/router and service layer
- **H2** persistent database for portal authentication, SMS NonConforming, and Training Tracker
- **Apache POI** (through Lucee/Java interop) for Excel ingestion and generation
- Existing **Tailwind/CSS/vanilla JavaScript** frontend preserved from the Flask project

## Included modules

- Portal authentication, users, permissions, and per-section access control
- Invoice Generator
  - Promethean Workshop Invoice
  - Promethean Storage / Small Parts Invoice
  - Promethean FedEx Shipment Upload
  - AMC Warehouse Invoice
  - TCL Warehouse Invoice
  - Philips Warehouse & Repair Invoice
  - Config/reference-data administration
- SMS NonConforming CRUD, search, XLSX export, numbering, and Zebra ZPL labels
- Training Tracker weeks, topics, sessions, roster, attendance/signatures, and reporting
- Generated-file access ownership/authorization

## Run locally

Install [CommandBox](https://www.ortussolutions.com/products/commandbox), then from the repository root:

```bash
box install commandbox-cfconfig --force
box server start
```

The server is configured by `server.json` and opens on:

```text
http://127.0.0.1:5000
```

Default first-run portal account:

```text
username: admin
password: admin
```

Change the password after first sign-in.

## Project layout

```text
Application.cfc                 Lucee application bootstrap + datasource
index.cfm                       Main router/API surface
services/
  AuthService.cfc               Users and permissions
  ConfigService.cfc             Pricing/reference configuration
  ExcelService.cfc              XLSX reading/writing with Apache POI
  InvoiceService.cfc            Invoice analysis/build engines
  NonConformingService.cfc      SMS NonConforming persistence/export/labels
  OutputService.cfc             Generated-file ownership + cleanup
  TrainingService.cfc           Training Tracker persistence/workflows
static/                         Preserved frontend CSS/JS/images
views/portal.html               Build-time-rendered portal shell
template/                       Original XLSX templates, preserved byte-for-byte
config/                         Imported reference/default JSON
migration/                      Source-template parity references + renderer
.github/workflows/              Asset sync and real Lucee smoke tests
```

## Source asset synchronization

`.github/workflows/import-source-assets.yml` checks out the original `Logicore-Portal` repository and copies unchanged frontend assets, XLSX templates, logos, and reference JSON into this repository. It also renders the original Jinja portal template into a static Lucee-compatible shell so the browser DOM/IDs and existing JavaScript contracts remain aligned with the original application.

Python/Jinja is used **only by this GitHub build-time migration workflow**. The application itself runs on Lucee/CFML and does not require Python.

## Compatibility goal

The port intentionally preserves the original public URL/API contract (`/sanitize`, `/analyze_storage`, `/analyze_amc`, `/analyze_tcl`, `/analyze_philips`, `/nonconforming/api/*`, `/training-tracker/*`, etc.) so the existing browser frontend continues to work without a simultaneous UI rewrite.

The original Python repository remains the behavior/reference implementation while parity testing is performed against this Lucee repository.
