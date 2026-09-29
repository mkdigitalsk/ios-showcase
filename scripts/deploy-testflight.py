#!/usr/bin/env python3
"""Archive the app and upload it to TestFlight from this Mac.

Nothing project-specific is written here: the scheme's signing team and the build counter come
from local.properties (ios.team.<track>, ios.build.number). Signing goes through the Xcode account
(Xcode > Settings > Accounts) via -allowProvisioningUpdates and never a key read from here —
"No signing certificate" means that account lacks access to the team.
"""

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = (Path(sys.argv[0]).parent / "..").resolve()
LOCAL_PROPERTIES = ROOT / "local.properties"
BUILD_DIR = ROOT / ".build" / "testflight"
BUILD_NUMBER_KEY = "ios.build.number"
PROJECT = "TemplateIOS.xcodeproj"
SCHEME = "TemplateIOS"
TRACKS = ("internal", "release")

EXPORT_OPTIONS = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key><string>app-store-connect</string>
    <key>destination</key><string>upload</string>
    <key>signingStyle</key><string>automatic</string>
    <key>teamID</key><string>{team}</string>
    <key>uploadSymbols</key><true/>
    <key>stripSwiftSymbols</key><true/>
    <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
"""


def die(message: str) -> None:
    print(f"❌ {message}", file=sys.stderr)
    raise SystemExit(1)


def read_properties() -> dict[str, str]:
    if not LOCAL_PROPERTIES.is_file():
        die(f"not found: {LOCAL_PROPERTIES} — copy local.properties.example and fill the TestFlight block")
    values = {}
    for line in LOCAL_PROPERTIES.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, _, value = line.partition("=")
            values[key.strip()] = value.strip()
    return values


def write_property(key: str, value: str) -> None:
    lines = LOCAL_PROPERTIES.read_text().splitlines()
    for i, line in enumerate(lines):
        if line.strip().startswith(f"{key}="):
            lines[i] = f"{key}={value}"
            break
    else:
        lines.append(f"{key}={value}")
    LOCAL_PROPERTIES.write_text("\n".join(lines) + "\n")


def current_revision() -> str:
    def git(*args: str) -> str:
        result = subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=False)
        return result.stdout.strip() if result.returncode == 0 else ""

    revision = git("rev-parse", "--short", "HEAD") or "no-git"
    if git("status", "--porcelain"):
        revision += "-dirty"
    return f"{git('rev-parse', '--abbrev-ref', 'HEAD') or '?'} @ {revision}"


def regenerate_project() -> None:
    """The .xcodeproj is derived from project.yml and ignored, so the archive is built from a fresh one."""
    subprocess.run(["xcodegen", "generate"], cwd=ROOT, check=True)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__.splitlines()[0],
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="local.properties supplies ios.team.<track> (the signing team, e.g. ios.team.internal=ABCDE12345)\n"
        "and ios.build.number, raised and written back after a successful upload.",
    )
    parser.add_argument(
        "--track",
        choices=TRACKS,
        default="internal",
        help="internal takes 0.0.<build> as its version; release keeps the project's",
    )
    parser.add_argument(
        "--build-number", type=int, help="a number; default is ios.build.number + 1, persisted on success"
    )
    parser.add_argument("--marketing-version", help="the version to stamp; internal defaults to 0.0.<build>")
    parser.add_argument("--no-upload", action="store_true", help="stop after archiving and open the archive in Xcode")
    parser.add_argument("--yes", action="store_true", help="skip the confirmation before uploading")
    parser.add_argument("--dry-run", action="store_true", help="print the plan and stop, building nothing")
    if len(sys.argv) == 1:
        parser.print_help()
        return
    args = parser.parse_args()

    properties = read_properties()
    team_key = f"ios.team.{args.track}"
    team = properties.get(team_key)
    if not team:
        die(f"{team_key} is missing in {LOCAL_PROPERTIES.name} — add the signing team for the {args.track} track")

    persist_from = None
    if args.build_number is None:
        persist_from = int(properties.get(BUILD_NUMBER_KEY, "0"))
        build_number = persist_from + 1
    else:
        build_number = args.build_number
    marketing = args.marketing_version or (f"0.0.{build_number}" if args.track == "internal" else None)

    print(f"Track:        {args.track} (team {team})")
    print(f"Source:       {current_revision()}")
    print(f"Build number: {build_number}")
    if marketing:
        print(f"Marketing:    {marketing}")
    if args.no_upload:
        print("Upload:       skipped (--no-upload)")
    if args.dry_run:
        print("Dry run — nothing archived, nothing uploaded.")
        return

    prompt = "Upload to TestFlight for every tester of this app? [y/N] "
    if not args.no_upload and not args.yes and sys.stdin.isatty() and input(prompt).strip().lower() not in {"y", "yes"}:
        print("Nothing uploaded.")
        return

    regenerate_project()

    archive_path = BUILD_DIR / f"{SCHEME}.xcarchive"
    subprocess.run(["rm", "-rf", str(BUILD_DIR)], check=True)
    BUILD_DIR.mkdir(parents=True)
    archive = [
        "xcodebuild",
        "archive",
        "-project",
        PROJECT,
        "-scheme",
        SCHEME,
        "-configuration",
        "Release",
        "-destination",
        "generic/platform=iOS",
        "-archivePath",
        str(archive_path),
        "-allowProvisioningUpdates",
        "COMPILER_INDEX_STORE_ENABLE=NO",
        "CODE_SIGN_STYLE=Automatic",
        f"DEVELOPMENT_TEAM={team}",
        f"CURRENT_PROJECT_VERSION={build_number}",
    ]
    if marketing:
        archive.append(f"MARKETING_VERSION={marketing}")
    try:
        subprocess.run(archive, cwd=ROOT, check=True)
    except subprocess.CalledProcessError as error:
        die(f"xcodebuild archive failed ({error.returncode}) — the output above says why; nothing was uploaded")

    if args.no_upload:
        if persist_from is not None:
            write_property(BUILD_NUMBER_KEY, str(build_number))
        print(f"✅ Archived → {archive_path}")
        subprocess.run(["open", str(archive_path)], check=False)
        return

    options = BUILD_DIR / "export-options.plist"
    options.write_text(EXPORT_OPTIONS.format(team=team))
    export = [
        "xcodebuild",
        "-exportArchive",
        "-archivePath",
        str(archive_path),
        "-exportOptionsPlist",
        str(options),
        "-exportPath",
        str(BUILD_DIR),
        "-allowProvisioningUpdates",
    ]
    export_log = BUILD_DIR / "export.log"
    with export_log.open("w", encoding="utf-8") as sink:
        process = subprocess.Popen(
            export, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1
        )
        for line in process.stdout:
            sink.write(line)
            print(line, end="")
    if process.wait() != 0:
        die(
            f"the upload failed ({process.returncode}) — the archive is kept at {archive_path}; rerun the export rather than rebuilding. Full output: {export_log}"
        )

    if persist_from is not None:
        write_property(BUILD_NUMBER_KEY, str(build_number))
    print(f"✅ Uploaded build {build_number} on the {args.track} track. Apple processes it for a few minutes.")
    print("   Watch it land:  App Store Connect > TestFlight")
    if persist_from is not None:
        print(f"   Next build takes {build_number + 1}; the counter lives in {LOCAL_PROPERTIES.name}.")


if __name__ == "__main__":
    main()
