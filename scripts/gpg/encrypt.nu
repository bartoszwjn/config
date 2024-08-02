#!/usr/bin/env nu

# Use gpg to encrypt a file for the given user ids
def main [
  file: path # File to encrypt
  ...users: string # Recipient user IDs
] {
  do -c { ^gpg --encrypt ...($users | each {|it| [--recipient $it]} | flatten) $file }
}
