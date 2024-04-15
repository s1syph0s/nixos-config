#!/bin/bash
LAYOUT=$(hyprctl devices | rg -A 2 'hp,-inc-hyperx-alloy-origins$' | grep keymap | awk '{ print $3 }')
[[ "$LAYOUT" == "English" ]] && echo "us" || echo "de"
