# -*- coding: utf-8 -*-
from __future__ import absolute_import, unicode_literals
from steganography.steganography import Steganography

output_path = "./output.jpg"
secret_text = Steganography.decode(output_path)
print(secret_text)
