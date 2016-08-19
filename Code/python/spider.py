# -*- coding: utf-8 -*-
import requests, os
from bs4 import BeautifulSoup

url = "http://www.c-bike.com.tw/Station1.aspx"
res = requests.get(url)
print(res)