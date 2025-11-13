#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "cryptography>=38.0.4",
#     "pyotp>=2.8.0",
# ]
# ///
import base64
import os
import pyotp
import json
import getpass
import time
import subprocess
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


def get_password_from_keychain(service_name, account_name):
    """Retrieve password from Mac Keychain and decode it from base64"""
    try:
        cmd = [
            "security",
            "find-generic-password",
            "-s",
            service_name,
            "-a",
            account_name,
            "-w",
        ]
        encoded_password = subprocess.check_output(cmd).decode("utf-8").strip()
        # Decode the password from base64
        decoded_password = base64.b64decode(encoded_password).decode("utf-8")
        return decoded_password
    except subprocess.CalledProcessError:
        print(
            f"Could not retrieve password for {service_name}/{account_name} from Keychain"
        )
        return None
    except base64.binascii.Error:
        print(
            f"Retrieved password is not valid base64 for {service_name}/{account_name}"
        )
        return None
    except UnicodeDecodeError:
        print(
            f"Decoded bytes could not be converted to UTF-8 for {service_name}/{account_name}"
        )
        return None


class OTPManager:
    def __init__(self):
        self.file_path = os.path.expanduser("~/.otp_secrets.enc")
        self.secrets = {}
        self.fernet = None

    def initialize_encryption(self, password=None):
        """Initialize encryption with a master password"""
        if password is None:
            password = getpass.getpass("Enter master password: ")

        # Generate a key from the password
        salt = b"static_salt_for_key_derivation"  # In a real app, store this securely
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        self.fernet = Fernet(key)

    def load_secrets(self):
        """Load encrypted secrets from file"""
        if not os.path.exists(self.file_path):
            return False

        try:
            with open(self.file_path, "rb") as f:
                encrypted_data = f.read()

            decrypted_data = self.fernet.decrypt(encrypted_data).decode("utf-8")
            self.secrets = json.loads(decrypted_data)
            return True
        except Exception as e:
            print(f"Error loading secrets: {e}")
            return False

    def save_secrets(self):
        """Save secrets to encrypted file"""
        try:
            data = json.dumps(self.secrets)
            encrypted_data = self.fernet.encrypt(data.encode("utf-8"))

            with open(self.file_path, "wb") as f:
                f.write(encrypted_data)

            # Set restrictive permissions on the file
            os.chmod(self.file_path, 0o600)
            return True
        except Exception as e:
            print(f"Error saving secrets: {e}")
            return False

    def add_secret(self, name, secret):
        """Add a new OTP secret"""
        # Validate the secret format
        try:
            # Test if we can create a valid OTP with this secret
            pyotp.TOTP(secret).now()
            self.secrets[name] = secret
            self.save_secrets()
            return True
        except Exception as e:
            print(f"Invalid secret format: {e}")
            return False

    def remove_secret(self, name):
        """Remove a secret by name"""
        if name in self.secrets:
            del self.secrets[name]
            self.save_secrets()
            return True
        return False

    def get_code(self, name):
        """Generate OTP code for a given name"""
        if name in self.secrets:
            totp = pyotp.TOTP(self.secrets[name])
            current_code = totp.now()
            next_code = totp.at(time.time() + 30)
            return current_code, next_code
        return None, None

    def list_names(self):
        """List all saved OTP names"""
        return list(self.secrets.keys())

    def get_raw_secrets(self):
        """Get the raw secrets JSON for display"""
        return json.dumps(self.secrets, indent=2)


def clear_screen():
    """Clear the terminal screen"""
    os.system("cls" if os.name == "nt" else "clear")


def dump_option(manager):
    """
    Display the contents of the encrypted keys file and wait for user input.

    Args:
        manager (OTPManager): The OTP manager instance
    """
    clear_screen()
    print("\033[1;34mDisplaying contents of encrypted keys file:\033[0m")
    print("\n")

    # Display the raw secrets data
    raw_secrets = manager.get_raw_secrets()
    print(raw_secrets)

    print("\n")
    input("Press Enter to continue...")


def main():
    # Configuration for keychain access
    KEYCHAIN_SERVICE = "OTPGenerator"
    KEYCHAIN_ACCOUNT = "MasterPassword"

    # Get password from keychain
    keychain_password = get_password_from_keychain(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT)

    manager = OTPManager()

    # Initialize with password from keychain if available, otherwise prompt
    manager.initialize_encryption(password=keychain_password)

    if os.path.exists(manager.file_path):
        if not manager.load_secrets():
            print("Failed to load secrets. Password might be incorrect.")
            return
    else:
        print("First time setup. Creating encrypted storage.")
        manager.save_secrets()

    while True:
        clear_screen()

        # Display remaining seconds for current OTP
        seconds_remaining = 30 - int(time.time()) % 30
        print(f"OTP Generator - New codes in {seconds_remaining} seconds")
        print("=" * 50)

        # Display current time
        current_time = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())
        print(f"Current Time (UTC): {current_time}")
        print("=" * 50)

        # List existing OTP entries with codes
        names = manager.list_names()
        if names:
            for idx, name in enumerate(sorted(names), 1):
                current_code, next_code = manager.get_code(name)
                print(
                    f"{idx}. {name}: Current OTP: {current_code}, Next OTP: {next_code}"
                )
        else:
            print("No OTP entries found. Add one using option 'a'.")

        print("\nOptions:")
        print("a - Add new OTP secret")
        print("r - Remove OTP secret")
        print("f - Refresh codes")
        print("d - Dump raw keys file contents")  # Added new option
        print("q - Quit")

        choice = input("\nEnter option: ").lower()

        if choice == "a":
            name = input("Enter name for the OTP: ")
            secret = input("Enter the secret key: ")
            if manager.add_secret(name, secret):
                print(f"Added OTP for {name}")
            else:
                print("Failed to add OTP. Invalid secret format.")
            input("Press Enter to continue...")

        elif choice == "r":
            name = input("Enter name of OTP to remove: ")
            if manager.remove_secret(name):
                print(f"Removed OTP for {name}")
            else:
                print(f"No OTP found with name {name}")
            input("Press Enter to continue...")

        elif choice == "f":
            # Refresh is just continuing the loop, which redraws the screen
            continue

        elif choice == "d":  # Added new case for dump option
            dump_option(manager)

        elif choice == "q":
            break

        # Refresh automatically to show updated codes
        elif choice == "":
            continue


if __name__ == "__main__":
    main()
