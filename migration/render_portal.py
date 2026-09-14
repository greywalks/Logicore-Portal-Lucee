#!/usr/bin/env python3
"""Build-time only: render the original Flask/Jinja portal into a static shell.

The resulting views/portal.html contains the exact working form markup/DOM IDs
used by static/js/app.js and nonconforming.js. Runtime authentication and route
permissions are enforced in CFML; static/js/lucee-auth.js hides navigation the
current user is not permitted to use.
"""
from __future__ import annotations
import argparse
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, StrictUndefined


def url_for(endpoint: str, **kwargs) -> str:
    mapping = {
        "admin_permissions": "/admin/permissions",
        "logout": "/logout",
        "index": "/",
        "login": "/login",
    }
    return mapping.get(endpoint, "/" + endpoint.replace("_", "/"))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", required=True)
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    source = Path(args.source)
    env = Environment(
        loader=FileSystemLoader(str(source.parent)),
        undefined=StrictUndefined,
        autoescape=False,
    )
    template = env.get_template(source.name)
    html = template.render(
        can_invoice_generator=True,
        can_sms_nonconforming=True,
        can_training_tracker=True,
        can_tbd2=True,
        default_portal="invoice-generator",
        default_client="promethean",
        ig_children=["promethean", "amc", "tcl", "philips", "config"],
        has_any_access=True,
        auth_user={
            "username": "__AUTH_USERNAME__",
            "is_superadmin": True,
        },
        url_for=url_for,
    )

    html = html.replace("Flask + Tailwind v9.0", "Lucee + Tailwind v9.0")
    html = html.replace("Python · Flask · Tailwind", "CFML · Lucee · Tailwind")
    html = html.replace('href="/admin/permissions"', 'id="admin-permissions-link" href="/admin/permissions"')
    html = html.replace('<script src="/static/js/app.js" defer></script>', '<script src="/static/js/lucee-auth.js" defer></script>\n<script src="/static/js/app.js" defer></script>')

    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(html, encoding="utf-8")


if __name__ == "__main__":
    main()
