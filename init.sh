#!/bin/bash 
set -exu

brew list bash || brew install bash
brew list pkg-config || brew install pkg-config
brew list automake || brew install automake
brew list meson || brew install meson
brew list ninja || brew install ninja
brew list cmake || brew install cmake
brew list nasm || brew install nasm
brew list sdl2 || brew install sdl2
brew list gnu-sed || brew install gnu-sed
