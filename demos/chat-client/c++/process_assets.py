#!env python3

# Python script from https://github.com/rjzak/web_wordpuzzle

ASSETS = ( ("jquery", open("assets/jquery-3.6.0.min.js", "rb").read()), ("chat", open("assets/chat.html", "rb").read()), )

output_file = open("assets.h", "w")

for asset in ASSETS:
    name = asset[0]
    data = asset[1]
    output_file.write("const unsigned char %s[%d]= {" % (name, len(data)));
    output_file.write(",".join(["0x%02X"%x for x in data]))
    output_file.write("};\n")


output_file.close()