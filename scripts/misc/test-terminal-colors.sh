#!/usr/bin/env bash

text=" Xyz "

csi=$'\033''['
reset="${csi}0m"
nums=(0 8 1 9 2 10 3 11 4 12 5 13 6 14 7 15)

fgs=("${csi}39m")
bgs=("${csi}49m")
for n in "${nums[@]}"; do
    fgs+=("${csi}38;5;${n}m")
    bgs+=("${csi}48;5;${n}m")
done

cols="          BG  BLK HBLK  RED HRED  GRN HGRN  YLW HYLW  BLU HBLU  MAG HMAG  CYA HCYA  WHI HWHI"
rows=(
    "   FG"
    "  BLK"
    "HIBLK"
    "  RED"
    "HIRED"
    "  GRN"
    "HIGRN"
    "  YLW"
    "HIYLW"
    "  BLU"
    "HIBLU"
    "  MAG"
    "HIMAG"
    "  CYA"
    "HICYA"
    "  WHI"
    "HIWHI"
)

printf "%s\n" "$cols"
for i in "${!fgs[@]}"; do
    printf " %s " "${rows[$i]}"
    for j in "${!bgs[@]}"; do
        printf "%s%s%s" "${fgs[$i]}" "${bgs[$j]}" "${text}"
    done
    printf "%s\n" "${reset}"
done
