echo "Cleaning up old outputs"
find raw/payments -type f ! -iname "*.zip" -delete
rm edits/payments/*
rm output/payments/*

sh process-payments.sh