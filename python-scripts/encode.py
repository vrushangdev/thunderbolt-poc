# -*- coding: utf-8 -*-
from __future__ import absolute_import, unicode_literals
from steganography.steganography import Steganography
from PIL import Image

path = "./test.jpeg"
output_path = "./output.jpg"
text = input("Enter What Ever You Want To Encode Into Image Or Video  ? ")
Steganography.encode(path, output_path, text)
output = Image.open("./output.jpg")
output.save("./compressed_output.jpg",optimize=True,quality=100)

