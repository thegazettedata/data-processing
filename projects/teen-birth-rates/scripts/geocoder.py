from csv import DictReader, DictWriter
from os import environ
from time import sleep
import requests
import sys

FNAME = 'edits/' + sys.argv[1] + '.csv'
ONAME = 'edits/' + sys.argv[1] + '-geo.csv'
API_KEY = 'mapzen-7NQi9Rj'
BASE_URL = 'https://search.mapzen.com/v1/search'

def foo_geocode(address_text, country = 'USA'):
  resp = requests.get(BASE_URL,
    params = {
      'api_key': API_KEY,
      'size': 1,
      'text': address_text,
      'boundary.country': country
    }
  )
  data = resp.json()
  bbox = data['bbox']
  pt = {}
  pt['lat'] = (bbox[1] + bbox[3]) / 2
  pt['lon'] = (bbox[0] + bbox[2]) / 2
  return pt


r = open(FNAME)
rcsv = DictReader(r)
w = open(ONAME, 'w')
wcsv = DictWriter(w, fieldnames = rcsv.fieldnames + ['latitude', 'longitude'])
wcsv.writeheader()
for row in rcsv:
  addr = "%s, %s, USA" % (row[sys.argv[2]], "IA")
  try:
    pt = foo_geocode(addr)
  except Exception as err:
    print(addr)
    print("\tError:", err)
  else:
    print(addr, pt['lat'], pt['lon'])
    row['latitude'] = pt['lat']
    row['longitude'] = pt['lon']
    wcsv.writerow(row)

    sleep(0.2)

w.close()
r.close()