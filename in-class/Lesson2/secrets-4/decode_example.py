import base64

input_string = "bXl1c2Vy"

decoded = base64.b64decode(input_string).decode("utf-8")

print(f'''
input_string: {input_string}
decoded: {decoded}
''')