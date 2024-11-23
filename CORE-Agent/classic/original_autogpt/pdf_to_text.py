import base64
import requests
import pandas as pd
import pdfplumber

from pdf2image import convert_from_path
from io import BytesIO
from PIL import Image

# Function to encode the image
def encode_image(image):
    buffer = BytesIO()
    image.save(buffer, format="JPEG")
    return base64.b64encode(buffer.getvalue()).decode('utf-8')

def pdf_converter_partial(api_key, org_id, pdf_path, reproduction_list):
  res = ""
  # Convert PDF to images
  images = convert_from_path(pdf_path)

  # Initialize headers
  headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}",
    "OpenAI-Organization": org_id
  }

  # Process each image from the PDF
  for i, image in enumerate(images):

      base64_image = encode_image(image)

      # Create payload for each image
      payload = {
        "model": "gpt-4o",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": f'''You are given an image that is part of a paper, and your task is to extract and only extract texts and formulas that are relevant to REPRODUCE {reproduction_list} in the paper.
                NOTE: you should NOT try to extract values directly from the tables and figures. 
                You should output empty string if none exists in the image. 
                There can be several text segments that are relevant.
                You should NOT extract anything that are irrelevant.'''
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": f"data:image/jpeg;base64,{base64_image}"
                }
              }
            ]
          }
        ],
        "max_tokens": 300
      }

      # Send the request to the API
      response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
      response_json = response.json()

      # Print the response
      print(f"Response for Page {i+1}:")
      print(response_json['choices'][0]['message']['content'])
      res += response_json['choices'][0]['message']['content']
      res += "\n"

  return res

# Open the PDF file
def pdf_converter_full(pdf_path):
  res = ""
  with pdfplumber.open(pdf_path) as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        res += text
        res += "\n"
  return res

