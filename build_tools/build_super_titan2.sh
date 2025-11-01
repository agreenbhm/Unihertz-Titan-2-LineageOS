#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $@ <unsparsed_stock_super.img> <lineage_gsi_image>"
    echo "Extracted system_dlkm, system_ext, vendor, vendor_dlkm, and odm_dlkm images must be in working directory"
    echo "Extract from unsparsed super.img with: lpunpack super.raw.img super_partitions/"
    echo "Unsparse sparsed super.img with: simg2img super.img super.raw.img"
    exit 1
fi

# inputs
#super_img=../super.raw.img
#system_img=$(ls -1 ../Lineage*.img | head -n1)
super_img="$1"
system_img="$2"

# sizes
superstat=$(stat -c '%s' "$super_img")
systemstat=$(stat -c '%s' "$system_img")
systemdlkmstat=$(stat -c '%s' system_dlkm_a.img)
systemextstat=$(stat -c '%s' system_ext_a.img)
vendorstat=$(stat -c '%s' vendor_a.img)
vendordlkmstat=$(stat -c '%s' vendor_dlkm_a.img)
odmdlkmstat=$(stat -c '%s' odm_dlkm_a.img)

groupstat=$((systemstat + systemdlkmstat + systemextstat + vendorstat + vendordlkmstat + odmdlkmstat))

echo "Super:        $superstat"
echo "System:       $systemstat"
echo "System_dlkm:  $systemdlkmstat"
echo "System_ext:   $systemextstat"
echo "Vendor:       $vendorstat"
echo "Vendor_dlkm:  $vendordlkmstat"
echo "ODM_dlkm:     $odmdlkmstat"
echo "Group:        $groupstat"

# build A-only super with one group "main"
lpmake \
  --virtual-ab \
  --metadata-size 65536 \
  --metadata-slots 2 \
  --super-name super \
  --device super:"$superstat" \
  --group main_a:"$groupstat" \
  \
  --partition system_a:none:"$systemstat":main_a \
  --image system_a="$system_img" \
  \
  --partition system_ext_a:readonly:"$systemextstat":main_a \
  --image system_ext_a=system_ext_a.img \
  \
  --partition system_dlkm_a:readonly:"$systemdlkmstat":main_a \
  --image system_dlkm_a=system_dlkm_a.img \
  \
  --partition vendor_a:readonly:"$vendorstat":main_a \
  --image vendor_a=vendor_a.img \
  \
  --partition vendor_dlkm_a:none:"$vendordlkmstat":main_a \
  --image vendor_dlkm_a=vendor_dlkm_a.img \
  \
  --partition odm_dlkm_a:readonly:"$odmdlkmstat":main_a \
  --image odm_dlkm_a=odm_dlkm_a.img \
  \
  --sparse \
  --output ./super.new.img
