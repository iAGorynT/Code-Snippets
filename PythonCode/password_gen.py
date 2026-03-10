#!/usr/bin/env python3
"""Maximum entropy pseudo-random password generator."""

# Uses 'secrets' module for cryptographically secure random generation (not 'random')
import secrets
import string
import argparse
import time
import subprocess
import platform


DEFAULT_LENGTH = 32
DEFAULT_CHARSET = string.ascii_letters + string.digits + string.punctuation


def generate_password(
    length: int = DEFAULT_LENGTH, charset: str = DEFAULT_CHARSET
) -> str:
    """Generate a maximum entropy password using cryptographically secure random bytes.

    Each symbol in the charset has equal probability of occurring at any position,
    ensuring maximum entropy and uniform randomness across all substrings.
    """
    # Core generation: secrets.choice() ensures each character is randomly selected
    return "".join(secrets.choice(charset) for _ in range(length))


def generate_with_timestamp(
    length: int, charset: str, include_date: bool = False
) -> str:
    """Generate password with timestamp prefix for uniqueness.

    Timestamp provides uniqueness guarantee while the random portion
    maintains maximum entropy properties.
    """
    # Convert timestamp to alphanumeric (digits become letters for consistency)
    if include_date:
        ts = time.strftime("%Y%m%d%H%M%S")
    else:
        ts = str(int(time.time()))

    ts_encoded = ""
    for c in ts:
        if c.isdigit():
            ts_encoded += string.ascii_letters[int(c)]
        elif c.isalpha():
            ts_encoded += c.upper()
        else:
            ts_encoded += c

    random_length = max(0, length - len(ts_encoded))
    random_part = generate_password(random_length, charset)

    result = ts_encoded + random_part
    return result


def copy_to_clipboard(text: str) -> bool:
    """Copy text to clipboard using platform-native command."""
    # Platform-specific clipboard handling: Darwin (macOS), Linux, or unsupported
    system = platform.system()
    try:
        if system == "Darwin":
            subprocess.run(["pbcopy"], input=text.encode(), check=True)
        elif system == "Linux":
            subprocess.run(
                ["xclip", "-selection", "clipboard"], input=text.encode(), check=True
            )
        else:
            return False
        return True
    except Exception:
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate maximum entropy pseudo-random passwords"
    )
    parser.add_argument(
        "-l",
        "--length",
        type=int,
        default=DEFAULT_LENGTH,
        help=f"Password length (default: {DEFAULT_LENGTH})",
    )
    parser.add_argument(
        "-c",
        "--charset",
        type=str,
        default=DEFAULT_CHARSET,
        help="Character set to use (default: alphanumeric + punctuation)",
    )
    parser.add_argument(
        "-n",
        "--no-special",
        action="store_true",
        help="Use alphanumeric only (a-z, A-Z, 0-9)",
    )
    parser.add_argument(
        "-d", "--digits-only", action="store_true", help="Use digits only (0-9)"
    )
    parser.add_argument(
        "-a", "--alpha-only", action="store_true", help="Use letters only (a-z, A-Z)"
    )
    parser.add_argument(
        "-s",
        "--simple",
        action="store_true",
        help="Use simple alphanumeric (lowercase + digits, excludes similar chars)",
    )
    parser.add_argument(
        "-m",
        "--max-entropy",
        action="store_true",
        help="Calculate and display the entropy in bits",
    )
    parser.add_argument(
        "-t",
        "--timestamp",
        action="store_true",
        help="Include timestamp prefix for uniqueness (format: YYYYMMDDHHMMSS)",
    )
    parser.add_argument(
        "-o",
        "--copy",
        action="store_true",
        help="Copy password to clipboard",
    )

    args = parser.parse_args()

    # Determine charset based on user options (priority: specific types > no-special > simple > default)
    if args.digits_only:
        charset = string.digits
    elif args.alpha_only:
        charset = string.ascii_letters
    elif args.no_special:
        charset = string.ascii_letters + string.digits
    elif args.simple:
        charset = "abcdefghjkmnpqrstuvwxyz23456789"
    else:
        charset = args.charset

    # Generate password: timestamp-prefixed or standard random
    if args.timestamp:
        password = generate_with_timestamp(args.length, charset, include_date=True)
    else:
        password = generate_password(args.length, charset)

    # Display entropy info if requested
    if args.max_entropy:
        entropy = len(charset) ** args.length
        entropy_bits = args.length * (len(charset).bit_length() - 1)
        print(f"Entropy: ~{entropy_bits} bits ({entropy:.2e} combinations)")
        print()

    # Output: print password and optionally copy to clipboard
    print(password)

    if args.copy:
        if copy_to_clipboard(password):
            print("Password copied to clipboard.")
        else:
            print("Failed to copy to clipboard.")


if __name__ == "__main__":
    main()
