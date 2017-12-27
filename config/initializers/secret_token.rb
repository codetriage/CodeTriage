# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
CodeTriage::Application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || 'ab37b1294efd8458ee5f186d1164e91bb234e123b8244fbc009f50b223a655f2b4265e519b93db715d9b3c8a382b7fe961ef9b2857105f14efaf32ce72f52e9e'
