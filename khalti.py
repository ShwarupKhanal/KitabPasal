import requests
import json
from flask import redirect

url = "https://a.khalti.com/api/v2/epayment/initiate/"

payload = json.dumps({
    "return_url": "http://127.0.0.1:3000/",
    "website_url": "http://127.0.0.1:3000/",
    "amount": "1000",
    "purchase_order_id": "Order01",
    "purchase_order_name": "test",
    "customer_info": {
    "name": "Ram Bahadur",
    "email": "test@khalti.com",
    "phone": "9800000001"
    }
})
headers = {
    'Authorization': 'key 0da482c13aef465f9d04dda5d782b855',
    'Content-Type': 'application/json',
}

response = requests.request("POST", url, headers=headers, data=payload)

print(response.text)