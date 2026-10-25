#!/usr/bin/env nu

# Use gpg to encrypt a file for the given user ids
export def main [
    file: path # File to encrypt
    ...users: string # Recipient user IDs
]: nothing -> nothing {
    gpg --encrypt ...($users | each --flatten { [--recipient $in] }) $file
}
