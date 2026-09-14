# Logicore Portal Lucee — Parity Validation

This document tracks runtime parity between `greywalks/Logicore-Portal` and this Lucee/CFML port.

## Runtime gate

- [ ] Lucee 7 boots cleanly on a fresh GitHub Actions runner.
- [ ] `/healthz` succeeds.
- [ ] `/login` renders and the default first-run administrator can authenticate.
- [ ] Authenticated portal shell renders.

## Portal and permissions

- [x] Portal users and per-module permissions are persisted in H2.
- [x] Invoice Generator child permissions are represented independently.
- [x] Training Tracker roles are represented as admin/editor/viewer.
- [x] Legacy `tbd2` permission remains compatible and is relabeled Inventory Management.
- [x] Generated output ownership is persisted rather than process-local.

## Invoice Generator

- [x] Promethean Workshop analysis/build routes are present.
- [x] Promethean Storage analysis/build routes are present.
- [x] Promethean FedEx Shipment routes are present.
- [x] AMC routes are present.
- [x] TCL routes are present.
- [x] Philips routes are present.
- [x] Config/reference-data routes are present.
- [ ] Authenticated endpoint smoke tests pass under Lucee.
- [ ] Billing fixtures are checked against current Python-main behavior.

## SMS NonConforming

- [x] CRUD/search persistence.
- [x] Number generation.
- [x] XLSX export through Apache POI.
- [x] Zebra ZPL label output.
- [ ] Authenticated endpoint smoke tests pass under Lucee.

## Training Tracker

- [x] Weeks/topics/videos/sessions/roster.
- [x] Attendance and digital signature persistence.
- [x] Physical sign-off PDF template.
- [x] Signed-sheet upload/view/remove.
- [x] Attendance-matrix XLSX report.
- [x] Signed-sheet ZIP report.
- [x] Editable content and appearance settings.
- [x] Flask-compatible route aliases.
- [ ] Authenticated endpoint smoke tests pass under Lucee.

## Inventory Management

- [x] Mounted at `/inventory-management/` using the legacy `tbd2` permission key.
- [x] Receiving/Shipping/Inventory/Repair/FedEx imports.
- [x] File SHA-256 and event fingerprint deduplication.
- [x] Serial/MSO/model lifecycle views.
- [x] Shipping reports and CSV/XLSX export.
- [x] Promethean reference/serial decoding and AP9-B `-02` rule.
- [x] Quality audit, serial overrides, and global whitelist.
- [x] Quality CSV/XLSX exports.
- [ ] Authenticated endpoint smoke tests pass under Lucee.

## Known source inconsistency to preserve during parity testing

The current Python `main` implementation of Philips `_split_base_credit()` applies the included 500 sq ft as a 250/250 Demo/Service split by default, even though older comments and a previously discussed billing expectation describe a different allocation. The Lucee port intentionally follows the executable current-source behavior until the billing rule is explicitly changed in both implementations.
