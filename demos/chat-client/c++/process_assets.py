# Python script from https://github.com/rjzak/web_wordpuzzle

ASSETS = ( ("index_page", open("assets/index.html", "rb").read()), ("script", open("assets/script.js", "rb").read()), ("style", open("assets/style.css", "rb").read()) )

output_file = open("assets.h", "w")

output_file.write("//This is an auto-generated file generated from the process_asets.py script\n\n")

for asset in ASSETS:
    name = asset[0]
    data = asset[1]
    output_file.write("unsigned char %s[%d]= {" % (name, len(data)));
    output_file.write(",".join(["0x%02X"%x for x in data]))
    output_file.write("};\n")


output_file.close()