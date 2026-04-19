"""
export CLI — convert data to various output formats.

Usage:
  python cli.py --output-format json --max-items 100 <input>
"""

import argparse


def main():
    parser = argparse.ArgumentParser(description="Export data to various formats")
    parser.add_argument(
        "--output-format",
        choices=["json", "csv", "yaml"],
        default="json",
        help="Output format (default: json)",
    )
    parser.add_argument(
        "--max-items",
        type=int,
        default=1000,
        help="Maximum number of items to export (default: 1000)",
    )
    parser.add_argument(
        "--pretty",
        action="store_true",
        help="Pretty-print output",
    )
    parser.add_argument("input", help="Input file path")
    args = parser.parse_args()
    print(f"Exporting {args.input} as {args.output_format} (max {args.max_items} items)")


if __name__ == "__main__":
    main()
